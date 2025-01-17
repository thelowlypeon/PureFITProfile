//
//  RecordMessage.swift
//  PureFITProfile
//
//  Created by Peter Compernolle on 1/16/25.
//

import Foundation

public final class RecordMessage: WrappedMessage<RecordMessage.Field> {
    public enum Field: UInt8 {
        case power = 7
        case timestamp = 253
    }

    public var power: Measurement<UnitPower>? {
        if case let .uint16(value) = value(at: .power) {
            return Measurement<UnitPower>(value: Double(value), unit: .watts)
        }
        return nil
    }

    public var timestamp: Date? {
        guard case .uint32(let val) = value(at: .timestamp) else { return nil }
        return Date(garminOffset: Double(val))
    }
}
