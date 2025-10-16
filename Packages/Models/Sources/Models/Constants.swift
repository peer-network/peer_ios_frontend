//
//  Constants.swift
//  Models
//
//  Created by Артем Васин on 30.12.24.
//

import Foundation

enum Constants {
//#if RELEASE
//    static let mediaURL: String = "https://media.peernetwork.eu"
//#else
    static let mediaURL: String = "https://media.getpeer.eu"
//#endif

//    static var mediaURL: String {
//        if let urlString = UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "customAPIEndpoint") {
//            return urlString.replacingOccurrences(of: "/graphql", with: "").replacingOccurrences(of: "//", with: "//media.")
//        }
//        return "https://media.peernetwork.eu"
//    }

    static let errorCodesURL = URL(string: "https://media.getpeer.eu/assets/response-codes.json")!
}
