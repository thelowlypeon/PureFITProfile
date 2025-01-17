//
//  FITMessageNumber.swift
//  PureFITProfile
//
//  Created by Peter Compernolle on 1/16/25.
//

public enum FITMessageNumber: RawRepresentable, Hashable {
    case fileId
    case capabilities
    case deviceSettings
    case userProfile
    case hrmProfile
    case sdmProfile
    case bikeProfile
    case zonesTarget
    case hrZone
    case powerZone
    case metZone
    case sport
    case goal
    case session
    case lap
    case record
    case event
    case deviceInfo
    case workout
    case workoutStep
    case schedule
    case weightScale
    case course
    case coursePoint
    case totals
    case activity
    case software
    case fileCapabilities
    case mesgCapabilities
    case fieldCapabilities
    case fileCreator
    case bloodPressure
    case speedZone
    case monitoring
    case trainingFile
    case hrv
    case length
    case monitoringInfo
    case pad
    case slaveDevice
    case connectivity
    case weatherConditions
    case weatherAlert
    case cad
    case fitnessEquipment
    case rower
    case treadMill
    case swimming
    case standUpPaddleBoard
    case elliptical
    case diving
    case exercise
    case waterSports
    case gymEquipment
    case lapDetail
    case opMode
    case extendedLap
    case lapSummary
    case lapPerformance
    case unknown(UInt16)

    public var rawValue: UInt16 {
        switch self {
        case .fileId: return 0
        case .capabilities: return 1
        case .deviceSettings: return 2
        case .userProfile: return 3
        case .hrmProfile: return 4
        case .sdmProfile: return 5
        case .bikeProfile: return 6
        case .zonesTarget: return 7
        case .hrZone: return 8
        case .powerZone: return 9
        case .metZone: return 10
        case .sport: return 12
        case .goal: return 15
        case .session: return 18
        case .lap: return 19
        case .record: return 20
        case .event: return 21
        case .deviceInfo: return 23
        case .workout: return 26
        case .workoutStep: return 27
        case .schedule: return 28
        case .weightScale: return 30
        case .course: return 31
        case .coursePoint: return 32
        case .totals: return 33
        case .activity: return 34
        case .software: return 35
        case .fileCapabilities: return 37
        case .mesgCapabilities: return 38
        case .fieldCapabilities: return 39
        case .fileCreator: return 49
        case .bloodPressure: return 51
        case .speedZone: return 53
        case .monitoring: return 55
        case .trainingFile: return 72
        case .hrv: return 78
        case .length: return 101
        case .monitoringInfo: return 103
        case .pad: return 105
        case .slaveDevice: return 106
        case .connectivity: return 127
        case .weatherConditions: return 128
        case .weatherAlert: return 129
        case .cad: return 131
        case .fitnessEquipment: return 134
        case .rower: return 135
        case .treadMill: return 136
        case .swimming: return 137
        case .standUpPaddleBoard: return 138
        case .elliptical: return 140
        case .diving: return 142
        case .exercise: return 150
        case .waterSports: return 151
        case .gymEquipment: return 158
        case .lapDetail: return 184
        case .opMode: return 185
        case .extendedLap: return 186
        case .lapSummary: return 187
        case .lapPerformance: return 188
        case .unknown(let value): return value
        }
    }

    public init(rawValue: UInt16) {
        switch rawValue {
        case 0: self = .fileId
        case 1: self = .capabilities
        case 2: self = .deviceSettings
        case 3: self = .userProfile
        case 4: self = .hrmProfile
        case 5: self = .sdmProfile
        case 6: self = .bikeProfile
        case 7: self = .zonesTarget
        case 8: self = .hrZone
        case 9: self = .powerZone
        case 10: self = .metZone
        case 12: self = .sport
        case 15: self = .goal
        case 18: self = .session
        case 19: self = .lap
        case 20: self = .record
        case 21: self = .event
        case 23: self = .deviceInfo
        case 26: self = .workout
        case 27: self = .workoutStep
        case 28: self = .schedule
        case 30: self = .weightScale
        case 31: self = .course
        case 32: self = .coursePoint
        case 33: self = .totals
        case 34: self = .activity
        case 35: self = .software
        case 37: self = .fileCapabilities
        case 38: self = .mesgCapabilities
        case 39: self = .fieldCapabilities
        case 49: self = .fileCreator
        case 51: self = .bloodPressure
        case 53: self = .speedZone
        case 55: self = .monitoring
        case 72: self = .trainingFile
        case 78: self = .hrv
        case 101: self = .length
        case 103: self = .monitoringInfo
        case 105: self = .pad
        case 106: self = .slaveDevice
        case 127: self = .connectivity
        case 128: self = .weatherConditions
        case 129: self = .weatherAlert
        case 131: self = .cad
        case 134: self = .fitnessEquipment
        case 135: self = .rower
        case 136: self = .treadMill
        case 137: self = .swimming
        case 138: self = .standUpPaddleBoard
        case 140: self = .elliptical
        case 142: self = .diving
        case 150: self = .exercise
        case 151: self = .waterSports
        case 158: self = .gymEquipment
        case 184: self = .lapDetail
        case 185: self = .opMode
        case 186: self = .extendedLap
        case 187: self = .lapSummary
        case 188: self = .lapPerformance
        default: self = .unknown(rawValue)
        }
    }
}

