//
//  WrappedMessage.swift
//  PureFITProfile
//
//  Created by Peter Compernolle on 1/16/25.
//

import PureFIT

public protocol MessageWrapper {
    associatedtype FieldType: RawRepresentable where FieldType.RawValue == UInt8

    var fitMessage: FITMessage { get }
    func value(at field: FieldType) -> FITValue?
}

public class WrappedMessage<F: RawRepresentable>: MessageWrapper where F.RawValue == UInt8 {
    public let fitMessage: FITMessage

    public init(fitMessage: FITMessage) {
        self.fitMessage = fitMessage
    }

    public func value(at field: F) -> FITValue? {
        return fitMessage.value(at: field.rawValue)
    }

    public var messageNumber: FITMessageNumber {
        return FITMessageNumber(rawValue: fitMessage.globalMessageNumber)
    }
}

