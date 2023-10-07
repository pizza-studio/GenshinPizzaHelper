import Combine
import Foundation

extension Defaults {
    /**
     Custom `Subscription` for `UserDefaults` key observation.
     */
    final class DefaultsSubscription<SubscriberType: Subscriber>: Subscription
        where SubscriberType.Input == BaseChange {
        // MARK: Lifecycle

        init(subscriber: SubscriberType, suite: UserDefaults, key: String, options: ObservationOptions) {
            self.subscriber = subscriber
            self.options = options
            self.observation = UserDefaultsKeyObservation(
                object: suite,
                key: key,
                callback: observationCallback(_:)
            )
        }

        // MARK: Internal

        func request(_ demand: Subscribers.Demand) {
            // Nothing as we send events only when they occur.
        }

        func cancel() {
            observation = nil
            subscriber = nil
        }

        func start() {
            observation?.start(options: options)
        }

        // MARK: Private

        private var subscriber: SubscriberType?
        private var observation: UserDefaultsKeyObservation?
        private let options: ObservationOptions

        private func observationCallback(_ change: BaseChange) {
            _ = subscriber?.receive(change)
        }
    }

    /**
     Custom Publisher, which is using DefaultsSubscription.
     */
    struct DefaultsPublisher: Publisher {
        // MARK: Lifecycle

        init(suite: UserDefaults, key: String, options: ObservationOptions) {
            self.suite = suite
            self.key = key
            self.options = options
        }

        // MARK: Internal

        typealias Output = BaseChange
        typealias Failure = Never

        func receive(subscriber: some Subscriber<Output, Failure>) {
            let subscription = DefaultsSubscription(
                subscriber: subscriber,
                suite: suite,
                key: key,
                options: options
            )

            subscriber.receive(subscription: subscription)
            subscription.start()
        }

        // MARK: Private

        private let suite: UserDefaults
        private let key: String
        private let options: ObservationOptions
    }

    /**
     Returns a type-erased `Publisher` that publishes changes related to the given key.

     ```swift
     extension Defaults.Keys {
     	static let isUnicornMode = Key<Bool>("isUnicornMode", default: false)
     }

     let publisher = Defaults.publisher(.isUnicornMode).map(\.newValue)

     let cancellable = publisher.sink { value in
     	print(value)
     	//=> false
     }
     ```

     - Warning: This method exists for backwards compatibility and will be deprecated sometime in the future. Use ``Defaults/updates(_:initial:)-9eh8`` instead.
     */
    public static func publisher<Value: Serializable>(
        _ key: Key<Value>,
        options: ObservationOptions = [.initial]
    ) -> AnyPublisher<KeyChange<Value>, Never> {
        let publisher = DefaultsPublisher(suite: key.suite, key: key.name, options: options)
            .map { KeyChange<Value>(change: $0, defaultValue: key.defaultValue) }

        return AnyPublisher(publisher)
    }

    /**
     Publisher for multiple `Key<T>` observation, but without specific information about changes.

     - Warning: This method exists for backwards compatibility and will be deprecated sometime in the future. Use ``Defaults/updates(_:initial:)-9eh8`` instead.
     */
    public static func publisher(
        keys: [_AnyKey],
        options: ObservationOptions = [.initial]
    ) -> AnyPublisher<(), Never> {
        let initial = Empty<(), Never>(completeImmediately: false).eraseToAnyPublisher()

        return
            keys
                .map { key in
                    DefaultsPublisher(suite: key.suite, key: key.name, options: options)
                        .map { _ in () }
                        .eraseToAnyPublisher()
                }
                .reduce(initial) { combined, keyPublisher in
                    combined.merge(with: keyPublisher).eraseToAnyPublisher()
                }
    }

    /**
     Publisher for multiple `Key<T>` observation, but without specific information about changes.

      - Warning: This method exists for backwards compatibility and will be deprecated sometime in the future. Use ``Defaults/updates(_:initial:)-9eh8`` instead.
     */
    public static func publisher(
        keys: _AnyKey...,
        options: ObservationOptions = [.initial]
    ) -> AnyPublisher<(), Never> {
        publisher(keys: keys, options: options)
    }
}
