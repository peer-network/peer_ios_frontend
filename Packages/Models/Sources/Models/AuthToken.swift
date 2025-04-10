//
//  AuthToken.swift
//  Models
//
//  Created by Alexander Savchenko on 02.04.25.
//

public struct AuthToken {
    public let accessToken: String
    public let refreshToken: String
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
