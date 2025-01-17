import Testing
import Foundation
@testable import PureFITProfile

@Test func testWorkOutDoorsFileParsing() async throws {
    let url = Bundle.module.url(forResource: "fitfile1", withExtension: "fit", subdirectory: "Fixtures")!
    let data = try Data(contentsOf: url)
    let fit = try FITFile(data: data)
    #expect(Int(fit.header.dataSize) + Int(fit.header.headerSize) + (fit.header.crc == nil ? 0 : 2) == 193162)
    let expectedMessageTypes: [FITMessageNumber] = [.fileId, .session, .lap, .record, .event, .deviceInfo, .activity, .unknown(206), .unknown(207)]
    for messageType in expectedMessageTypes {
        #expect(fit.messages[messageType]?.isEmpty == false)
    }
    #expect(fit.messages.values.reduce(0, { $0 + $1.count }) == 4285)
    let fileIdMessage = try #require(fit.messages[.fileId]?.first as? FileIdMessage)
    #expect(fileIdMessage.messageNumber == .fileId)
    #expect(fileIdMessage.serialNumber == 282475249)
    #expect(fileIdMessage.productName == nil)

    let deviceInfoMessages = try #require(fit.messages[.deviceInfo] as? [DeviceInfoMessage])
    let deviceInfoMessage = try #require(deviceInfoMessages.first)
    #expect(deviceInfoMessage.messageNumber == .deviceInfo)
    #expect(deviceInfoMessage.productName == "WorkOutDoors")
    #expect(deviceInfoMessage.serialNumber == 282475249)

    let recordMessages = try #require(fit.messages[.record] as? [RecordMessage])
    let recordMessage = try #require(recordMessages.first)
    #expect(recordMessage.messageNumber == .record)
    #expect(recordMessage.timestamp?.timeIntervalSince1970 == 1727608596)
    #expect(recordMessage.power?.converted(to: .watts).value == 190)
}
