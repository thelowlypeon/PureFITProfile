//
//  DeviceInfoMessage.swift
//  PureFITProfile
//
//  Created by Peter Compernolle on 1/16/25.
//

public final class DeviceInfoMessage: WrappedMessage<DeviceInfoMessage.Field> {
    public enum Field: UInt8 {
        case serialNumber = 3
        case productName = 27
    }

    public var serialNumber: UInt32? {
        guard case .uint32z(let val) = value(at: .serialNumber) else { return nil }
        return val
    }

    public var productName: String? {
        guard case .string(let str) = value(at: .productName) else { return nil }
        return str
    }
}
