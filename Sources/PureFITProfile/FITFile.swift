//
//  FITFile.swift
//  PureFITProfile
//
//  Created by Peter Compernolle on 1/16/25.
//

import Foundation
import PureFIT

public struct FITFile {
    public let header: FITHeader
    public let messages: [FITMessageNumber: [any MessageWrapperProtocol]]

    public init(url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }

    public init(data: Data) throws {
        let rawFit = try RawFITFile(data: data)
        let pureFit = try PureFITFile(rawFITFile: rawFit)
        self.header = pureFit.header
        let wrappedMessages = pureFit.messages.map { $0.wrap() }
        self.messages = Dictionary(grouping: wrappedMessages, by: { message in
            FITMessageNumber(rawValue: message.fitMessage.globalMessageNumber)
        })
    }
}
