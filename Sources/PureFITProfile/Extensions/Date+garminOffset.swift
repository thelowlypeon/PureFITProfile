//
//  Date+garminOffset.swift
//  PureFITProfile
//
//  Created by Peter Compernolle on 1/16/25.
//

import Foundation

extension Date {
    public init(garminOffset: Double) {
        self.init(timeIntervalSince1970: garminOffset + 631065600)
    }
}
