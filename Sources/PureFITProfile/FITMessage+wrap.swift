//
//  FITMessage+wrap.swift
//  PureFITProfile
//
//  Created by Peter Compernolle on 1/16/25.
//

import PureFIT

extension FITMessage {
    public func wrap() -> any MessageWrapperProtocol {
        // TODO: i don't love how this is the source of truth. i've already forgotten to update it twice!
        switch globalMessageNumber {
        case 0: return FileIdMessage(fitMessage: self)
        case 20: return RecordMessage(fitMessage: self)
        case 23: return DeviceInfoMessage(fitMessage: self)
        default: return UnrecognizedMessage(fitMessage: self)
        }
    }
}
