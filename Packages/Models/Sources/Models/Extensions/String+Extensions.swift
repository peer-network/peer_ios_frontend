//
//  String+Extensions.swift
//  Models
//
//  Created by Artem Vasin on 06.03.25.
//

import Foundation

extension String {
    func timeAgo(isShort: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Server time is in UTC
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let serverDate = dateFormatter.date(from: self) else {
            return ""
        }

        let userTimeZone = TimeZone.current
        let userCalendar = Calendar.current

        // Adjust from CET to user's current timezone
        let userDate = serverDate.addingTimeInterval(Double(
            userTimeZone.secondsFromGMT(for: serverDate) -
            TimeZone(abbreviation: "CET")!.secondsFromGMT(for: serverDate)
        ))

        let now = Date()
        let components = userCalendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: userDate,
            to: now
        )

        if let year = components.year, year >= 1 || (components.month ?? 0) >= 1 {
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.timeZone = userTimeZone
            return dateFormatter.string(from: userDate)
        }

        if let day = components.day, day > 0 {
            return isShort ? "\(day)d" : "\(day)d ago"
        }
        if let hour = components.hour, hour > 0 {
            return isShort ? "\(hour)h" : "\(hour)h ago"
        }
        if let minute = components.minute, minute > 0 {
            return isShort ? "\(minute)min" : "\(minute)min ago"
        }
        if let second = components.second, second > 5 {
            return isShort ? "\(second)s" : "\(second)sec ago"
        }

        return isShort ? "now" : "just now"
    }
}
