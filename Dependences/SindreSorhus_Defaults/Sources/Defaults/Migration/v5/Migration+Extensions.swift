import CoreGraphics
import Foundation

extension Defaults {
    public typealias NativeType = _DefaultsNativeType
    public typealias CodableType = _DefaultsCodableType
}

// MARK: - Data + Defaults.NativeType

extension Data: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Data + Defaults.CodableType

extension Data: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Date + Defaults.NativeType

extension Date: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Date + Defaults.CodableType

extension Date: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Bool + Defaults.NativeType

extension Bool: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Bool + Defaults.CodableType

extension Bool: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Int + Defaults.NativeType

extension Int: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Int + Defaults.CodableType

extension Int: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - UInt + Defaults.NativeType

extension UInt: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - UInt + Defaults.CodableType

extension UInt: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Double + Defaults.NativeType

extension Double: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Double + Defaults.CodableType

extension Double: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Float + Defaults.NativeType

extension Float: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Float + Defaults.CodableType

extension Float: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - String + Defaults.NativeType

extension String: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - String + Defaults.CodableType

extension String: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - CGFloat + Defaults.NativeType

extension CGFloat: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - CGFloat + Defaults.CodableType

extension CGFloat: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Int8 + Defaults.NativeType

extension Int8: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Int8 + Defaults.CodableType

extension Int8: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - UInt8 + Defaults.NativeType

extension UInt8: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - UInt8 + Defaults.CodableType

extension UInt8: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Int16 + Defaults.NativeType

extension Int16: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Int16 + Defaults.CodableType

extension Int16: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - UInt16 + Defaults.NativeType

extension UInt16: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - UInt16 + Defaults.CodableType

extension UInt16: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Int32 + Defaults.NativeType

extension Int32: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Int32 + Defaults.CodableType

extension Int32: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - UInt32 + Defaults.NativeType

extension UInt32: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - UInt32 + Defaults.CodableType

extension UInt32: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Int64 + Defaults.NativeType

extension Int64: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - Int64 + Defaults.CodableType

extension Int64: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - UInt64 + Defaults.NativeType

extension UInt64: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - UInt64 + Defaults.CodableType

extension UInt64: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - URL + Defaults.NativeType

extension URL: Defaults.NativeType {
    public typealias CodableForm = Self
}

// MARK: - URL + Defaults.CodableType

extension URL: Defaults.CodableType {
    public typealias NativeForm = Self

    public func toNative() -> Self { self }
}

// MARK: - Optional + Defaults.NativeType

extension Optional: Defaults.NativeType where Wrapped: Defaults.NativeType {
    public typealias CodableForm = Wrapped.CodableForm
}

extension Defaults.CollectionSerializable where Self: Defaults.NativeType, Element: Defaults.NativeType {
    public typealias CodableForm = [Element.CodableForm]
}

extension Defaults.SetAlgebraSerializable where Self: Defaults.NativeType, Element: Defaults.NativeType {
    public typealias CodableForm = [Element.CodableForm]
}

extension Defaults.CodableType where Self: RawRepresentable<NativeForm.RawValue>, NativeForm: RawRepresentable {
    public func toNative() -> NativeForm {
        NativeForm(rawValue: rawValue)!
    }
}

// MARK: - Set + Defaults.NativeType

extension Set: Defaults.NativeType where Element: Defaults.NativeType {
    public typealias CodableForm = [Element.CodableForm]
}

// MARK: - Array + Defaults.NativeType

extension Array: Defaults.NativeType where Element: Defaults.NativeType {
    public typealias CodableForm = [Element.CodableForm]
}

// MARK: - Array + Defaults.CodableType

extension Array: Defaults.CodableType where Element: Defaults.CodableType {
    public typealias NativeForm = [Element.NativeForm]

    public func toNative() -> NativeForm {
        map { $0.toNative() }
    }
}

// MARK: - Dictionary + Defaults.NativeType

extension Dictionary: Defaults.NativeType where Key: LosslessStringConvertible & Hashable, Value: Defaults.NativeType {
    public typealias CodableForm = [String: Value.CodableForm]
}

// MARK: - Dictionary + Defaults.CodableType

extension Dictionary: Defaults.CodableType where Key == String, Value: Defaults.CodableType {
    public typealias NativeForm = [String: Value.NativeForm]

    public func toNative() -> NativeForm {
        reduce(into: NativeForm()) { memo, tuple in
            memo[tuple.key] = tuple.value.toNative()
        }
    }
}
