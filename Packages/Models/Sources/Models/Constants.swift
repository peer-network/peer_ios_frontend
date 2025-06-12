//
//  Constants.swift
//  Models
//
//  Created by Артем Васин on 30.12.24.
//

import Foundation

enum Constants {
    static let mediaURL: String = "https://media.peernetwork.eu"
//    static let mediaURL: String = "https://media.getpeer.eu"

//    static var mediaURL: String {
//        if let urlString = UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "customAPIEndpoint") {
//            return urlString.replacingOccurrences(of: "/graphql", with: "").replacingOccurrences(of: "//", with: "//media.")
//        }
//        return "https://media.peernetwork.eu"
//    }

    static let errorCodesURL = URL(string: "https://media.getpeer.eu/assets/response-codes.json")!
}

//import Foundation
//
//enum Constants {
//    public static var mediaURL: URL {
//        let berlinTime = getCurrentBerlinTime()
//        let cutoffDate = createCutoffDate()
//
//        return berlinTime < cutoffDate ?
//            URL(string: "https://media.getpeer.eu")! :
//            URL(string: "https://media.peernetwork.eu")!
//    }
//
//    static let errorCodesURL = URL(string: "https://media.getpeer.eu/assets/response-codes.json")!
//
//    private static func getCurrentBerlinTime() -> Date {
//        let timeZone = TimeZone(identifier: "Europe/Berlin")!
//        let utcDate = Date()
//        let secondsFromGMT = timeZone.secondsFromGMT(for: utcDate)
//        return utcDate.addingTimeInterval(TimeInterval(secondsFromGMT))
//    }
//
//    private static func createCutoffDate() -> Date {
//        let timeZone = TimeZone(identifier: "Europe/Berlin")!
//        var calendar = Calendar.current
//        calendar.timeZone = timeZone
//
//        var components = DateComponents()
//        components.year = 2025
//        components.month = 5
//        components.day = 19
//        components.hour = 15
//        components.minute = 0
//        components.second = 0
//
//        return calendar.date(from: components)!
//    }
//}
