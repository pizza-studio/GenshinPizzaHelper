import Combine
import SwiftUI

extension Defaults {
    @MainActor
    final class Observable<Value: Serializable>: ObservableObject {
        // MARK: Lifecycle

        init(_ key: Key<Value>) {
            self.key = key

            // We only use this on the latest OSes (as of adding this) since the backdeploy library has a lot of bugs.
            if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
                // The `@MainActor` is important as the `.send()` method doesn't inherit the `@MainActor` from the class.
                self.task = .detached(priority: .userInitiated) { @MainActor [weak self] in
                    for await _ in Defaults.updates(key) {
                        guard let self else {
                            return
                        }

                        self.objectWillChange.send()
                    }
                }
            } else {
                self.cancellable = Defaults.publisher(key, options: [.prior])
                    .sink { [weak self] change in
                        guard change.isPrior else {
                            return
                        }

                        Task { @MainActor in
                            self?.objectWillChange.send()
                        }
                    }
            }
        }

        deinit {
            task?.cancel()
        }

        // MARK: Internal

        let objectWillChange = ObservableObjectPublisher()

        var value: Value {
            get { Defaults[key] }
            set {
                objectWillChange.send()
                Defaults[key] = newValue
            }
        }

        /**
         Reset the key back to its default value.
         */
        func reset() {
            key.reset()
        }

        // MARK: Private

        private var cancellable: AnyCancellable?
        private var task: Task<(), Never>?
        private let key: Defaults.Key<Value>
    }
}

// MARK: - Default

/**
 Access stored values from SwiftUI.

 This is similar to `@AppStorage` but it accepts a ``Defaults/Key`` and many more types.
 */
@propertyWrapper
public struct Default<Value: Defaults.Serializable>: DynamicProperty {
    // MARK: Lifecycle

    /**
     Get/set a `Defaults` item and also have the view be updated when the value changes. This is similar to `@State`.

     - Important: You cannot use this in an `ObservableObject`. It's meant to be used in a `View`.

     ```swift
     extension Defaults.Keys {
     	static let hasUnicorn = Key<Bool>("hasUnicorn", default: false)
     }

     struct ContentView: View {
     	@Default(.hasUnicorn) var hasUnicorn

     	var body: some View {
     		Text("Has Unicorn: \(hasUnicorn)")
     		Toggle("Toggle", isOn: $hasUnicorn)
     		Button("Reset") {
     			_hasUnicorn.reset()
     		}
     	}
     }
     ```
     */
    public init(_ key: Defaults.Key<Value>) {
        self.key = key
        self.observable = .init(key)
    }

    // MARK: Public

    public typealias Publisher = AnyPublisher<Defaults.KeyChange<Value>, Never>

    public var wrappedValue: Value {
        get { observable.value }
        nonmutating set {
            observable.value = newValue
        }
    }

    public var projectedValue: Binding<Value> { $observable.value }

    /**
     The default value of the key.
     */
    public var defaultValue: Value { key.defaultValue }

    /**
     Combine publisher that publishes values when the `Defaults` item changes.
     */
    public var publisher: Publisher { Defaults.publisher(key) }

    public mutating func update() {
        _observable.update()
    }

    /**
     Reset the key back to its default value.

     ```swift
     extension Defaults.Keys {
     	static let opacity = Key<Double>("opacity", default: 1)
     }

     struct ContentView: View {
     	@Default(.opacity) var opacity

     	var body: some View {
     		Button("Reset") {
     			_opacity.reset()
     		}
     	}
     }
     ```
     */
    public func reset() {
        key.reset()
    }

    // MARK: Private

    private let key: Defaults.Key<Value>

    // Intentionally using `@ObservedObjected` over `@StateObject` so that the key can be dynamically changed.
    @ObservedObject
    private var observable: Defaults.Observable<Value>
}

extension Default where Value: Equatable {
    /**
     Indicates whether the value is the same as the default value.
     */
    public var isDefaultValue: Bool { wrappedValue == defaultValue }
}

@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
extension Defaults {
    /**
     A SwiftUI `Toggle` view that is connected to a ``Defaults/Key`` with a `Bool` value.

     The toggle works exactly like the SwiftUI `Toggle`.

     ```swift
     extension Defaults.Keys {
     	static let showAllDayEvents = Key<Bool>("showAllDayEvents", default: false)
     }

     struct ShowAllDayEventsSetting: View {
     	var body: some View {
     		Defaults.Toggle("Show All-Day Events", key: .showAllDayEvents)
     	}
     }
     ```

     You can also listen to changes:

     ```swift
     struct ShowAllDayEventsSetting: View {
     	var body: some View {
     		Defaults.Toggle("Show All-Day Events", key: .showAllDayEvents)
     			// Note that this has to be directly attached to `Defaults.Toggle`. It's not `View#onChange()`.
     			.onChange {
     				print("Value", $0)
     			}
     	}
     }
     ```
     */
    public struct Toggle<Label: View>: View {
        // MARK: Lifecycle

        public init(key: Defaults.Key<Bool>, @ViewBuilder label: @escaping () -> Label) {
            self.label = label
            self.observable = .init(key)
        }

        // MARK: Public

        public var body: some View {
            SwiftUI.Toggle(isOn: $observable.value, label: label)
                .onChange(of: observable.value) {
                    onChange?($0)
                }
        }

        // MARK: Private

        @ViewStorage
        private var onChange: ((Bool) -> ())?

        private let label: () -> Label

        // Intentionally using `@ObservedObjected` over `@StateObject` so that the key can be dynamically changed.
        @ObservedObject
        private var observable: Defaults.Observable<Bool>
    }
}

@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
extension Defaults.Toggle<Text> {
    public init(_ title: some StringProtocol, key: Defaults.Key<Bool>) {
        self.label = { Text(title) }
        self.observable = .init(key)
    }
}

@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
extension Defaults.Toggle {
    /**
     Do something when the value changes to a different value.
     */
    public func onChange(_ action: @escaping (Bool) -> ()) -> Self {
        onChange = action
        return self
    }
}

// MARK: - ViewStorage

@propertyWrapper
private struct ViewStorage<Value>: DynamicProperty {
    // MARK: Lifecycle

    init(wrappedValue value: @autoclosure @escaping () -> Value) {
        self._valueBox = .init(wrappedValue: ValueBox(value()))
    }

    // MARK: Internal

    var wrappedValue: Value {
        get { valueBox.value }
        nonmutating set {
            valueBox.value = newValue
        }
    }

    // MARK: Private

    private final class ValueBox {
        // MARK: Lifecycle

        init(_ value: Value) {
            self.value = value
        }

        // MARK: Internal

        var value: Value
    }

    @State
    private var valueBox: ValueBox
}
