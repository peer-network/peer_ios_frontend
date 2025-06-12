//
//  Date+Extensions.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import Foundation

extension Date {
    var formattedWithMicroseconds: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // consistent formatting
        dateFormatter.timeZone = TimeZone.current // or use .utc for UTC

        let mainPart = dateFormatter.string(from: self)
        let microseconds = Int((self.timeIntervalSince1970.truncatingRemainder(dividingBy: 1)) * 1_000_000)
        let microPart = String(format: "%06d", microseconds)

        return "\(mainPart).\(microPart)"
    }
}
