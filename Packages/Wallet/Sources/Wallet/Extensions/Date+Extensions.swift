//
//  Date+Extensions.swift
//  Wallet
//
//  Created by Artem Vasin on 28.02.25.
//

import Foundation

extension Date {
    func convertToTimeZone(_ timeZone: TimeZone) -> Date {
        let currentOffset = TimeZone.current.secondsFromGMT(for: self)
        let targetOffset = timeZone.secondsFromGMT(for: self)
        let timeInterval = TimeInterval(targetOffset - currentOffset)
        return addingTimeInterval(timeInterval)
    }
}
