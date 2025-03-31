//
//  Constants.swift
//  Networking
//
//  Created by Артем Васин on 30.12.24.
//

import Foundation

public enum Constants {
//    static let apiURL = URL(string: "https://peernetwork.eu/graphql")!
    static let apiURL = URL(string: "https://getpeer.eu/graphql")!

    public static let accessTokenKey = "access_token"
    public static let refreshTokenKey = "refresh_token"
    static let accessTokenExpiryKey = "access_token_expiry"
}
