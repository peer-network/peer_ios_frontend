//
//  Constants.swift
//  Networking
//
//  Created by Артем Васин on 30.12.24.
//

import Foundation

public enum Constants {
    static let apiURL = URL(string: "https://peernetwork.eu/graphql")!
//    static let apiURL = URL(string: "https://getpeer.eu/graphql")!

    public static let accessTokenKey = "access_token"
    public static let refreshTokenKey = "refresh_token"
    static let accessTokenExpiryKey = "access_token_expiry"
}

//import Foundation
//
//public enum Constants {
//    public static var apiURL: URL {
//        let berlinTime = getCurrentBerlinTime()
//        let cutoffDate = createCutoffDate()
//
//        return berlinTime < cutoffDate ?
//            URL(string: "https://getpeer.eu/graphql")! :
//            URL(string: "https://peernetwork.eu/graphql")!
//    }
//
//    public static let accessTokenKey = "access_token"
//    public static let refreshTokenKey = "refresh_token"
//    static let accessTokenExpiryKey = "access_token_expiry"
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
