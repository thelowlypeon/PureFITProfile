//
//  UnrecognizedMessage.swift
//  PureFITProfile
//
//  Created by Peter Compernolle on 1/16/25.
//

public final class UnrecognizedMessage: WrappedMessage<UnrecognizedMessage.Field> {
    public enum Field: UInt8 {
        case timestamp = 253
    }
}
