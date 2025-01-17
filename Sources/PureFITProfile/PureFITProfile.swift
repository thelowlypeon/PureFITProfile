
import PureFIT
import Foundation

//
//  FITFieldValue.swift
//  PureFIT
//
//  Created by Peter Compernolle on 1/11/25.
//

/*
public enum FITMessageType: Hashable, Sendable {
    case fieldDescription
    case record
    case unknown(UInt16)

    internal init(rawValue: UInt16) {
        switch rawValue {
        case 20: self = .record
        case 206: self = .fieldDescription
        default:
            self = .unknown(rawValue)
        }
    }
}

protocol FITFieldType: Hashable {
    init(rawValue: UInt8)
}

protocol FITMessage {
    associatedtype FieldKey: FITFieldType

    var rawValues: [FieldKey: InterpretedFITValue] { get }
    var developerRawValues: [UInt8: InterpretedFITValue] { get }

    subscript(field: FieldKey) -> FITValue? { get }

    init(fields: [InterpretedFITField], developerFields: [UInt8: InterpretedFITValue])
}

extension Array where Element == InterpretedFITField {
    internal func indexValues<Key: Hashable>(withKey keyFromFITFieldClosure: (Element) -> Key) -> [Key: InterpretedFITValue] {
        return Dictionary(map { (keyFromFITFieldClosure($0), $0.interpretedValue) }, uniquingKeysWith: { left, right in
            if case .multiple(let values) = left {
                return .multiple(values + [right])
            } else {
                return .multiple([left, right])
            }
        })
    }
}

public protocol FITEnum {
    var stringValue: String { get }
}

public enum FITValue {
    case length(Measurement<UnitLength>)
    case angle(Measurement<UnitAngle>)
    case speed(Measurement<UnitSpeed>)
    case power(Measurement<UnitPower>)
    case temperature(Measurement<UnitTemperature>)
    case frequency(Measurement<UnitFrequency>) // should this be a custom dimension to avoid precision weirdness?
    case energy(Measurement<UnitEnergy>)
    case duration(TimeInterval)
    case pressure(Measurement<UnitPressure>)
    case percent(Double)
    case volume(Measurement<UnitVolume>)
    case mass(Measurement<UnitMass>)

    // primitives
    case int(value: Int, unit: String?)
    case double(value: Double, unit: String?)
    case `enum`(any FITEnum)
    case string(String)
    case date(Date)

    public static func fromUnknown(value: InterpretedFITValue) -> FITValue? {
        switch value {
        case .byte(let bytes): return .string("\(bytes)")
        case .enum(let val): return .string("\(val)")
        // TODO...
        default: return nil
        }
    }

    public func localizedString(locale: Locale = .current) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.unitOptions = .providedUnit
        switch self {
        case .length(let measurement):
            return formatter.string(from: measurement)
        default:
            return "\(self)"
        }

    }
}

extension FITBaseType: FITEnum {
    public var stringValue: String {
        return "Base type \(rawValue)" // TODO
    }
}

public struct FieldDescriptionMessage: FITMessage, Sendable {
    typealias FieldKey = StandardField

    public enum StandardField: FITFieldType, Sendable {
        init(rawValue: UInt8) {
            switch rawValue {
            case 0: self = .developerDataIndex
            case 1: self = .developerFieldDefinitionNumber
            case 2: self = .baseTypeRawValue
            case 3: self = .fieldName
            case 6: self = .scale
            case 7: self = .offset
            case 8: self = .units
            case 13: self = .baseUnits
            case 14: self = .messageNumber
            case 15: self = .fieldNumber
            default: self = .unknown(rawValue)
            }
        }

        case developerDataIndex
        case developerFieldDefinitionNumber
        case baseTypeRawValue
        case fieldName
        case scale
        case offset
        case units
        case baseUnits
        case messageNumber
        case fieldNumber
        case unknown(UInt8)
    }

    public var rawValues: [StandardField: InterpretedFITValue]
    public var developerRawValues: [UInt8 : InterpretedFITValue]

    public subscript(field: StandardField) -> FITValue? {
        switch field {
        case .developerDataIndex:
            guard let int = rawValues[field]?.intValue else { return nil }
            return .int(value: int, unit: nil) // TODO: this should be an enum
        case .developerFieldDefinitionNumber:
            guard let int = rawValues[field]?.intValue else { return nil }
            return .int(value: int, unit: nil) // TODO: this should be an enum
        case .baseTypeRawValue:
            guard case .uint8(let rawValue) = rawValues[field],
                  let baseType = FITBaseType(rawValue: rawValue) else { return nil }
            return .enum(baseType)
        case .fieldName:
            guard let str =  rawValues[field]?.stringValue else { return nil }
            return .string(str)
        case .scale:
            guard let val = rawValues[field]?.doubleValue else { return nil }
            return .double(value: val, unit: nil)
        case .offset:
            guard case .uint8(let rawValue) = rawValues[field] else { return nil }
            return .int(value: Int(rawValue), unit: nil)
        case .units:
            guard case .string(let str) = rawValues[field] else { return nil }
            return .string(str)

        default: return nil
        }
    }

    internal init(fields: [InterpretedFITField], developerFields: [UInt8 : InterpretedFITValue]) {
        self.rawValues = fields.indexValues(withKey: { StandardField(rawValue: $0.fieldDefinitionNumber) })
        self.developerRawValues = developerFields
    }

    public var developerDataIndex: UInt8? {
        guard case .uint8(let value) = rawValues[.developerDataIndex] else { return nil }
        return value
    }

    public var deverloperFieldDefinitionNumber: UInt8? {
        guard case .uint8(let value) = rawValues[.developerFieldDefinitionNumber] else { return nil }
        return value
    }
}

public struct FITRecordMessage: FITMessage, Sendable {
    public enum StandardField: FITFieldType, Sendable {
        case timestamp
        case latitude
        case longitude
        case power
        case unknown(UInt8)

        internal init(rawValue: UInt8) {
            switch rawValue {
            case 253: self = .timestamp
            case 0: self = .latitude
            case 1: self = .longitude
            default: self = .unknown(rawValue)
            }
        }
    }
    typealias FieldKey = StandardField

    public let rawValues: [StandardField: InterpretedFITValue]
    public let developerRawValues: [UInt8: InterpretedFITValue]

    public subscript(field: StandardField) -> FITValue? {
        guard let val = rawValues[field] else { return nil }
        switch field {
        case .timestamp:
            guard case .uint32(let secondsSinceGarminEpoch) = val else { return nil }
            return .date(Date(timeIntervalSince1970: Double(secondsSinceGarminEpoch))) // TODO, obvs
        case .power:
            guard case .uint16(let power) = val else { return nil }
            return .power(.init(value: Double(power), unit: .watts))
            /*
        case .developerDataIndex:
            guard let int = rawValues[field]?.intValue else { return nil }
            return .int(value: int, unit: nil) // TODO: this should be an enum
        case .developerFieldDefinitionNumber:
            guard let int = rawValues[field]?.intValue else { return nil }
            return .int(value: int, unit: nil) // TODO: this should be an enum
        case .baseTypeRawValue:
            guard case .uint8(let rawValue) = rawValues[field],
                  let baseType = FITBaseType(rawValue: rawValue) else { return nil }
            return .enum(baseType)
        case .fieldName:
            guard let str =  rawValues[field]?.stringValue else { return nil }
            return .string(str)
        case .scale:
            guard let val = rawValues[field]?.doubleValue else { return nil }
            return .double(value: val, unit: nil)
        case .offset:
            guard case .uint8(let rawValue) = rawValues[field] else { return nil }
            return .int(value: Int(rawValue), unit: nil)
        case .units:
            guard case .string(let str) = rawValues[field] else { return nil }
            return .string(str)
             */

        default: return nil
        }
    }

    internal init(fields: [InterpretedFITField], developerFields: [UInt8: InterpretedFITValue]) {
        self.rawValues = fields.indexValues(withKey: { StandardField(rawValue: $0.fieldDefinitionNumber) })
        self.developerRawValues = developerFields
    }

    public var timestamp: Date? {
        guard case .uint32(let value) = rawValues[.timestamp] else { return nil }
        return Date(timeIntervalSince1970: Double(value)) // TODO: garmin offset
    }
}

public struct FITUnknownMessage: FITMessage, Sendable {
    public enum StandardField: FITFieldType, Sendable {
        case unknown(UInt8)

        internal init(rawValue: UInt8) {
            switch rawValue {
            default: self = .unknown(rawValue)
            }
        }
    }
    typealias FieldKey = StandardField

    public let rawValues: [StandardField: InterpretedFITValue]
    public let developerRawValues: [UInt8: InterpretedFITValue]

    init(fields: [InterpretedFITField], developerFields: [UInt8 : InterpretedFITValue]) {
        self.rawValues = fields.indexValues(withKey: { StandardField(rawValue: $0.fieldDefinitionNumber) })
        self.developerRawValues = developerFields
    }

    public subscript(field: StandardField) -> FITValue? {
        guard let value = rawValues[field] else { return nil }
        return FITValue.fromUnknown(value: value)
    }
}


struct MyFITFile {
    let header: FITHeader // rename to PureFITHeader
    let messages: [FITMessageType: [any FITMessage]]
}



public enum FITBaseType: UInt8 {
    case `enum` = 0x00       // Enum type, invalid value: 0xFF, size: 1 byte
    case sint8 = 0x01        // Signed 8-bit integer, 2's complement, invalid value: 0x7F, size: 1 byte
    case uint8 = 0x02        // Unsigned 8-bit integer, invalid value: 0xFF, size: 1 byte
    case sint16 = 0x83       // Signed 16-bit integer, 2's complement, invalid value: 0x7FFF, size: 2 bytes
    case uint16 = 0x84       // Unsigned 16-bit integer, invalid value: 0xFFFF, size: 2 bytes
    case sint32 = 0x85       // Signed 32-bit integer, 2's complement, invalid value: 0x7FFFFFFF, size: 4 bytes
    case uint32 = 0x86       // Unsigned 32-bit integer, invalid value: 0xFFFFFFFF, size: 4 bytes
    case string = 0x07       // Null-terminated string encoded in UTF-8, invalid value: 0x00, size: 1 byte
    case float32 = 0x88      // 32-bit floating point, invalid value: 0xFFFFFFFF, size: 4 bytes
    case float64 = 0x89      // 64-bit floating point, invalid value: 0xFFFFFFFFFFFFFFFF, size: 8 bytes
    case uint8z = 0x0A       // Unsigned 8-bit integer with zero invalid, invalid value: 0x00, size: 1 byte
    case uint16z = 0x8B      // Unsigned 16-bit integer with zero invalid, invalid value: 0x0000, size: 2 bytes
    case uint32z = 0x8C      // Unsigned 32-bit integer with zero invalid, invalid value: 0x00000000, size: 4 bytes
    case byte = 0x0D         // Array of bytes, invalid if all bytes are invalid, invalid value: 0xFF, size: 1 byte
    case sint64 = 0x8E       // Signed 64-bit integer, 2's complement, invalid value: 0x7FFFFFFFFFFFFFFF, size: 8 bytes
    case uint64 = 0x8F       // Unsigned 64-bit integer, invalid value: 0xFFFFFFFFFFFFFFFF, size: 8 bytes
    case uint64z = 0x90      // Unsigned 64-bit integer with zero invalid, invalid value: 0x0000000000000000, size: 8 bytes

    public var isEndianCapable: Bool {
        switch self {
        case .sint16, .uint16, .sint32, .uint32, .float32, .float64, .uint16z, .uint32z, .sint64, .uint64, .uint64z:
            return true
        default:
            return false
        }
    }

    public var size: Int? {
        switch self {
        case .enum, .sint8, .uint8, .uint8z, .byte: return 1
        case .sint16, .uint16, .uint16z: return 2
        case .sint32, .uint32, .float32, .uint32z: return 4
        case .sint64, .uint64, .uint64z, .float64: return 8
        case .string:
            return nil // null terminated
        }
    }
}


public enum InterpretedFITValue: Sendable {
    case `enum`(UInt8)       // Enum type, associated value: UInt8
    case sint8(Int8)         // Signed 8-bit integer, associated value: Int8
    case uint8(UInt8)        // Unsigned 8-bit integer, associated value: UInt8
    case sint16(Int16)       // Signed 16-bit integer, associated value: Int16
    case uint16(UInt16)      // Unsigned 16-bit integer, associated value: UInt16
    case sint32(Int32)       // Signed 32-bit integer, associated value: Int32
    case uint32(UInt32)      // Unsigned 32-bit integer, associated value: UInt32
    case string(String)      // String type, associated value: String
    case float32(Float)      // 32-bit floating point, associated value: Float
    case float64(Double)     // 64-bit floating point, associated value: Double
    case uint8z(UInt8)       // Unsigned 8-bit integer with zero invalid, associated value: UInt8
    case uint16z(UInt16)     // Unsigned 16-bit integer with zero invalid, associated value: UInt16
    case uint32z(UInt32)     // Unsigned 32-bit integer with zero invalid, associated value: UInt32
    case byte([UInt8])       // Byte array, associated value: Array of UInt8
    case sint64(Int64)       // Signed 64-bit integer, associated value: Int64
    case uint64(UInt64)      // Unsigned 64-bit integer, associated value: UInt64
    case uint64z(UInt64)     // Unsigned 64-bit integer with zero invalid, associated value: UInt64
    case multiple([InterpretedFITValue]) // for cases where the same field exists multiple times in a single message
}

extension InterpretedFITValue: Equatable {}

extension InterpretedFITValue {
    public var doubleValue: Double? {
        switch self {
        case .float32(let value):
            return Double(value)
        case .float64(let double):
            return double
        default:
            return nil
        }
    }

    public var intValue: Int? {
        switch self {
        case .enum(let value): return Int(value)
        case .sint8(let value): return Int(value)
        case .uint8(let value): return Int(value)
        case .sint16(let value): return Int(value)
        case .uint16(let value): return Int(value)
        case .sint32(let value): return Int(value)
        case .uint32(let value): return Int(value)
        case .uint8z(let value): return Int(value)
        case .uint16z(let value): return Int(value)
        case .uint32z(let value): return Int(value)
        case .sint64(let value): return Int(value)
        case .uint64(let value): return Int(value)
        case .uint64z(let value): return Int(value)
        default: return nil
        }
    }

    public var stringValue: String? {
        switch self {
        case .string(let str): return str
        default: return nil
        }
    }

    /*
    var value: Any {
        switch self {
        case .enum(let value): return value
        case .sint8(let value): return value
        case .uint8(let value): return value
        case .sint16(let value): return value
        case .uint16(let value): return value
        case .sint32(let value): return value
        case .uint32(let value): return value
        case .string(let value): return value
        case .float32(let value): return value
        case .float64(let value): return value
        case .uint8z(let value): return value
        case .uint16z(let value): return value
        case .uint32z(let value): return value
        case .byte(let value): return value
        case .sint64(let value): return value
        case .uint64(let value): return value
        case .uint64z(let value): return value
        case .multiple(let values): return values.map { $0.value }
        }
    }
     */

}

/*
extension InterpretedFITValue {
    /// Returns `nil` if the associated value is the type's "invalid" sentinel,
    /// otherwise returns `self`.
    public var validated: InterpretedFITValue? {
        switch self {
        case .enum(let value):
            // Invalid sentinel: 0xFF
            return (value == 0xFF) ? nil : self
        case .uint8(let value):
            // Invalid sentinel: 0xFF
            return (value == 0xFF) ? nil : self
        case .byte(let array):
            // For .byte, the invalid sentinel is 0xFF for each byte
            return array.allSatisfy({ $0 == 0xFF }) ? nil : self
        case .sint8(let value):
            // Invalid sentinel: 0x7F
            return (value == 0x7F) ? nil : self
        case .sint16(let value):
            // Invalid sentinel: 0x7FFF
            return (value == 0x7FFF) ? nil : self
        case .uint16(let value):
            // Invalid sentinel: 0xFFFF
            return (value == 0xFFFF) ? nil : self
        case .uint16z(let value):
            // Invalid sentinel: 0xFFFF
            return (value == 0xFFFF) ? nil : self
        case .sint32(let value):
            // Invalid sentinel: 0x7FFFFFFF
            return (value == 0x7FFFFFFF) ? nil : self
        case .uint32(let value):
            // Invalid sentinel: 0xFFFFFFFF
            return (value == 0xFFFFFFFF) ? nil : self
        case .float32(let floatValue):
            // Under the FIT spec, 0xFFFFFFFF as a UInt32 representation of Float is invalid.
            // i.e. bitPattern == 0xFFFFFFFF
            // You can use Float(bitPattern:) if you need that.
            return (floatValue.bitPattern == 0xFFFFFFFF) ? nil : self
        case .uint32z(let value):
            // Invalid sentinel: 0xFFFFFFFF
            return (value == 0xFFFFFFFF) ? nil : self
        case .string(let str):
            // Invalid sentinel: 0x00 implies an empty or zero-terminated string is invalid.
            return str.isEmpty ? nil : self
        case .float64(let doubleValue):
            // Invalid sentinel: 0xFFFFFFFFFFFFFFFF as the bit pattern
            return (doubleValue.bitPattern == 0xFFFFFFFFFFFFFFFF) ? nil : self
        case .uint64(let value):
            // Invalid sentinel: 0xFFFFFFFFFFFFFFFF
            return (value == 0xFFFFFFFFFFFFFFFF) ? nil : self
        case .uint64z(let value):
            // Invalid sentinel: 0x0000000000000000
            return (value == 0x0000000000000000) ? nil : self
        case .sint64(let value):
            // Invalid sentinel: 0x7FFFFFFFFFFFFFFF
            return (value == 0x7FFFFFFFFFFFFFFF) ? nil : self
        case .multiple(let values):
            let filtered = values.compactMap { $0.validated }
            switch filtered.count {
            case 0: return nil
            case 1: return filtered.first!
            default: return .multiple(filtered)
            }
        case .uint8z(let value):
            return (value == 0x00) ? nil : self
        }
    }
}
 */


public struct UninterpretedFITField {
    public let fieldDefinitionNumber: FITFieldDefinitionNumber
    public let bytes: [UInt8]
}

extension InterpretedFITValue {
    static func from(
        bytes: [UInt8],
        baseType: FITBaseType,
        architecture: FITArchitecture
    ) -> InterpretedFITValue? {
        // Ensure there are enough bytes for the specified type
        guard bytes.count >= (baseType.size ?? 1) else { return nil }

        // Extract the relevant slice of bytes
        let slice = bytes[0..<(baseType.size ?? 1)]

        // Endianness conversion helper
        func convertEndian<T: FixedWidthInteger>(_ value: T) -> T {
            switch architecture {
            case .littleEndian:
                return T(littleEndian: value)
            case .bigEndian:
                return T(bigEndian: value)
            }
        }

        // Parse and immediately check for "invalid" sentinel values.
        switch baseType {
        case .enum:
            // Invalid if 0xFF
            let value = slice.first ?? 0xFF
            guard value != 0xFF else { return nil }
            return .enum(value)

        case .sint8:
            // Invalid if 0x7F
            let value = Int8(bitPattern: slice.first ?? 0x7F)
            guard value != 0x7F else { return nil }
            return .sint8(value)

        case .uint8:
            // Invalid if 0xFF
            let value = slice.first ?? 0xFF
            guard value != 0xFF else { return nil }
            return .uint8(value)

        case .sint16:
            // Invalid if 0x7FFF
            let raw = slice.withUnsafeBytes { $0.load(as: Int16.self) }
            let value = convertEndian(raw)
            guard value != 0x7FFF else { return nil }
            return .sint16(value)

        case .uint16:
            // Invalid if 0xFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: UInt16.self) }
            let value = convertEndian(raw)
            guard value != 0xFFFF else { return nil }
            return .uint16(value)

        case .sint32:
            // Invalid if 0x7FFFFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: Int32.self) }
            let value = convertEndian(raw)
            guard value != 0x7FFFFFFF else { return nil }
            return .sint32(value)

        case .uint32:
            // Invalid if 0xFFFFFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: UInt32.self) }
            let value = convertEndian(raw)
            guard value != 0xFFFFFFFF else { return nil }
            return .uint32(value)

        case .string:
            // Often in FIT, an empty or all-null string is invalid.
            // This logic treats an empty string as invalid.
            if let nullTerminatedString = String(bytes: bytes, encoding: .utf8)?
                .split(separator: "\0", maxSplits: 1, omittingEmptySubsequences: true)
                .first
            {
                let str = String(nullTerminatedString)
                guard !str.isEmpty else { return nil }
                return .string(str)
            }
            return nil

        case .float32:
            // Invalid if bitPattern == 0xFFFFFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: UInt32.self) }
            let converted = convertEndian(raw)
            guard converted != 0xFFFFFFFF else { return nil }
            return .float32(Float(bitPattern: converted))

        case .float64:
            // Invalid if bitPattern == 0xFFFFFFFFFFFFFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: UInt64.self) }
            let converted = convertEndian(raw)
            guard converted != 0xFFFFFFFFFFFFFFFF else { return nil }
            return .float64(Double(bitPattern: converted))

        case .uint8z:
            // Invalid if 0x00
            let value = slice.first ?? 0x00
            guard value != 0x00 else { return nil }
            return .uint8z(value)

        case .uint16z:
            // Invalid if 0xFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: UInt16.self) }
            let value = convertEndian(raw)
            guard value != 0xFFFF else { return nil }
            return .uint16z(value)

        case .uint32z:
            // Invalid if 0xFFFFFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: UInt32.self) }
            let value = convertEndian(raw)
            guard value != 0xFFFFFFFF else { return nil }
            return .uint32z(value)

        case .byte:
            // Some FIT specs treat an array of 0xFF as invalid
            let array = Array(slice)
            guard !array.allSatisfy({ $0 == 0xFF }) else { return nil }
            return .byte(array)

        case .sint64:
            // Invalid if 0x7FFFFFFFFFFFFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: Int64.self) }
            let value = convertEndian(raw)
            guard value != 0x7FFFFFFFFFFFFFFF else { return nil }
            return .sint64(value)

        case .uint64:
            // Invalid if 0xFFFFFFFFFFFFFFFF
            let raw = slice.withUnsafeBytes { $0.load(as: UInt64.self) }
            let value = convertEndian(raw)
            guard value != 0xFFFFFFFFFFFFFFFF else { return nil }
            return .uint64(value)

        case .uint64z:
            // Invalid if 0x0000000000000000
            let raw = slice.withUnsafeBytes { $0.load(as: UInt64.self) }
            let value = convertEndian(raw)
            guard value != 0x0000000000000000 else { return nil }
            return .uint64z(value)
        }
    }

}


public struct InterpretedFITField {
    public let fieldDefinitionNumber: FITFieldDefinitionNumber
    public let interpretedValue: InterpretedFITValue
}

public struct InterpretedFITMessage {
    public let globalMessageNumber: FITGlobalMessageNumber
    public let fields: [InterpretedFITField]
    public let developerFields: [UninterpretedFITField]

    // NOTE: this is O(n)
    public func first(fieldDefinitionNumber: UInt8) -> InterpretedFITField? {
        return fields.first(where: { $0.fieldDefinitionNumber == fieldDefinitionNumber })
    }

    // NOTE: this is O(n)
    public func first(developerFieldDefinitionNumber: UInt8) -> UninterpretedFITField? {
        return developerFields.first(where: { $0.fieldDefinitionNumber == developerFieldDefinitionNumber })
    }

    internal init(dataRecord: FITDataRecord, definitionRecord: FITDefinitionRecord) {
        var offset = 0
        let fields: [InterpretedFITField] = definitionRecord.fields.compactMap { field in
            let fieldSize = Int(field.size)
            let value = InterpretedFITValue.from(
                bytes: Array(dataRecord.fieldsData.bytes[offset..<(offset + fieldSize)]),
                baseType: FITBaseType(rawValue: field.baseType)!,
                architecture: definitionRecord.architecture
            )
            offset += fieldSize
            guard let value else { return nil }
            return .init(fieldDefinitionNumber: field.fieldDefinitionNumber, interpretedValue: value)
        }

        offset = 0
        let developerFields: [UninterpretedFITField] = definitionRecord.developerFields.compactMap { field in
            let fieldSize = Int(field.size)
            // if we can't find the base type, just get a big value
            guard dataRecord.developerFieldsData.bytes.count >= (offset + fieldSize) else { return nil }
            let bytes = dataRecord.developerFieldsData.bytes[offset..<(offset + fieldSize)]
            offset += fieldSize
            return .init(
                fieldDefinitionNumber: field.developerFieldDefinitionNumber,
                bytes: Array(bytes)
            )
        }

        self.globalMessageNumber = dataRecord.globalMessageNumber
        self.fields = fields
        self.developerFields = developerFields
    }
}

public struct FITFile {
    public let header: FITHeader
    public let messages: [InterpretedFITMessage]
    public let undefinedDataRecords: [FITDataRecord]?

    public init(data: Data) throws {
        let fit = try PureFIT.FITFile(data: data)
        self.init(pureFITFile: fit)
    }

    public init(pureFITFile fitFile: PureFIT.FITFile) {
        var messages = [InterpretedFITMessage]()
        var definitionsByMessageNumber = [FITGlobalMessageNumber: FITDefinitionRecord]()
        var undefinedDataRecords = [FITDataRecord]()
        for record in fitFile.records {
            switch record {
            case .definition(let definitionRecord):
                definitionsByMessageNumber[definitionRecord.globalMessageNumber] = definitionRecord
            case .data(let dataRecord):
                guard let definition = definitionsByMessageNumber[dataRecord.globalMessageNumber]
                else {
                    undefinedDataRecords.append(dataRecord)
                    continue
                }
                let message = InterpretedFITMessage(
                    dataRecord: dataRecord,
                    definitionRecord: definition
                )
                messages.append(message)
            }
        }

        self.header = fitFile.header
        self.messages = messages
        self.undefinedDataRecords = undefinedDataRecords.isEmpty ? nil : undefinedDataRecords
    }
}

*/


import Foundation

/* delete until here */
