import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Defaults.Serializable {
    public static var isNativelySupportedType: Bool { false }
}

// MARK: - Data + Defaults.Serializable

extension Data: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Date + Defaults.Serializable

extension Date: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Bool + Defaults.Serializable

extension Bool: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Int + Defaults.Serializable

extension Int: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - UInt + Defaults.Serializable

extension UInt: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Double + Defaults.Serializable

extension Double: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Float + Defaults.Serializable

extension Float: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - String + Defaults.Serializable

extension String: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - CGFloat + Defaults.Serializable

extension CGFloat: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Int8 + Defaults.Serializable

extension Int8: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - UInt8 + Defaults.Serializable

extension UInt8: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Int16 + Defaults.Serializable

extension Int16: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - UInt16 + Defaults.Serializable

extension UInt16: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Int32 + Defaults.Serializable

extension Int32: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - UInt32 + Defaults.Serializable

extension UInt32: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - Int64 + Defaults.Serializable

extension Int64: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - UInt64 + Defaults.Serializable

extension UInt64: Defaults.Serializable {
    public static let isNativelySupportedType = true
}

// MARK: - URL + Defaults.Serializable

extension URL: Defaults.Serializable {
    public static let bridge = Defaults.URLBridge()
}

extension Defaults.Serializable where Self: Codable {
    public static var bridge: Defaults.TopLevelCodableBridge<Self> { Defaults.TopLevelCodableBridge() }
}

extension Defaults.Serializable where Self: Codable & NSSecureCoding & NSObject {
    public static var bridge: Defaults.CodableNSSecureCodingBridge<Self> { Defaults.CodableNSSecureCodingBridge() }
}

extension Defaults.Serializable where Self: Codable & NSSecureCoding & NSObject & Defaults.PreferNSSecureCoding {
    public static var bridge: Defaults.NSSecureCodingBridge<Self> { Defaults.NSSecureCodingBridge() }
}

extension Defaults.Serializable where Self: Codable & RawRepresentable {
    public static var bridge: Defaults.RawRepresentableCodableBridge<Self> { Defaults.RawRepresentableCodableBridge() }
}

extension Defaults.Serializable where Self: Codable & RawRepresentable & Defaults.PreferRawRepresentable {
    public static var bridge: Defaults.RawRepresentableBridge<Self> { Defaults.RawRepresentableBridge() }
}

extension Defaults.Serializable where Self: RawRepresentable {
    public static var bridge: Defaults.RawRepresentableBridge<Self> { Defaults.RawRepresentableBridge() }
}

extension Defaults.Serializable where Self: NSSecureCoding & NSObject {
    public static var bridge: Defaults.NSSecureCodingBridge<Self> { Defaults.NSSecureCodingBridge() }
}

// MARK: - Optional + Defaults.Serializable

extension Optional: Defaults.Serializable where Wrapped: Defaults.Serializable {
    public static var isNativelySupportedType: Bool { Wrapped.isNativelySupportedType }
    public static var bridge: Defaults.OptionalBridge<Wrapped> { Defaults.OptionalBridge() }
}

extension Defaults.CollectionSerializable where Element: Defaults.Serializable {
    public static var bridge: Defaults.CollectionBridge<Self> { Defaults.CollectionBridge() }
}

extension Defaults.SetAlgebraSerializable where Element: Defaults.Serializable & Hashable {
    public static var bridge: Defaults.SetAlgebraBridge<Self> { Defaults.SetAlgebraBridge() }
}

// MARK: - Set + Defaults.Serializable

extension Set: Defaults.Serializable where Element: Defaults.Serializable {
    public static var bridge: Defaults.SetBridge<Element> { Defaults.SetBridge() }
}

// MARK: - Array + Defaults.Serializable

extension Array: Defaults.Serializable where Element: Defaults.Serializable {
    public static var isNativelySupportedType: Bool { Element.isNativelySupportedType }
    public static var bridge: Defaults.ArrayBridge<Element> { Defaults.ArrayBridge() }
}

// MARK: - Dictionary + Defaults.Serializable

extension Dictionary: Defaults.Serializable where Key: LosslessStringConvertible & Hashable,
    Value: Defaults.Serializable {
    public static var isNativelySupportedType: Bool { (Key.self is String.Type) && Value.isNativelySupportedType }
    public static var bridge: Defaults.DictionaryBridge<Key, Value> { Defaults.DictionaryBridge() }
}

// MARK: - UUID + Defaults.Serializable

extension UUID: Defaults.Serializable {
    public static let bridge = Defaults.UUIDBridge()
}

// MARK: - Color + Defaults.Serializable

@available(
    iOS 15.0,
    macOS 11.0,
    tvOS 15.0,
    watchOS 8.0,
    iOSApplicationExtension 15.0,
    macOSApplicationExtension 11.0,
    tvOSApplicationExtension 15.0,
    watchOSApplicationExtension 8.0,
    *
)
extension Color: Defaults.Serializable {
    public static let bridge = Defaults.ColorBridge()
}

// MARK: - Range + Defaults.RangeSerializable

extension Range: Defaults.RangeSerializable where Bound: Defaults.Serializable {
    public static var bridge: Defaults.RangeBridge<Range> { Defaults.RangeBridge() }
}

// MARK: - ClosedRange + Defaults.RangeSerializable

extension ClosedRange: Defaults.RangeSerializable where Bound: Defaults.Serializable {
    public static var bridge: Defaults.RangeBridge<ClosedRange> { Defaults.RangeBridge() }
}

#if os(macOS)
/**
 `NSColor` conforms to `NSSecureCoding`, so it goes to `NSSecureCodingBridge`.
 */
extension NSColor: Defaults.Serializable {}
#else
/**
 `UIColor` conforms to `NSSecureCoding`, so it goes to `NSSecureCodingBridge`.
 */
extension UIColor: Defaults.Serializable {}
#endif
