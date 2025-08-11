//
//  TokenKeychainManager.swift
//  TokenKeychainManager
//
//  Created by Артем Васин on 30.01.25.
//

import KeychainSwift
import Foundation

public final class TokenKeychainManager {
    public static let shared = TokenKeychainManager()
    
    lazy private var keychain = KeychainSwift()
    
    private init() {
    }
    
    // MARK: - Public Access
    
    public func getAccessToken() -> String? {
        keychain.get(Constants.accessTokenKey)
    }
    
    public func getRefreshToken() -> String? {
        keychain.get(Constants.refreshTokenKey)
    }
    
    public var isAccessTokenExpired: Bool {
        guard let token = getAccessToken() else { return true }
        return isTokenExpired(token)
    }
    
    public var isRefreshTokenExpired: Bool {
        guard let token = getRefreshToken() else { return true }
        return isTokenExpired(token)
    }
    
    /// Writes tokens to keychain
    public func setCredentials(accessToken: String, refreshToken: String) {
        keychain.set(accessToken, forKey: Constants.accessTokenKey)
        keychain.set(refreshToken, forKey: Constants.refreshTokenKey)
    }
    
    /// Removes tokens from keychain
    public func removeCredentials() {
        keychain.delete(Constants.accessTokenKey)
        keychain.delete(Constants.refreshTokenKey)
    }
    
    // MARK: - Helpers
    
    /// Quick check if token is expired by decoding JWT 'exp' claim
    private func isTokenExpired(_ token: String) -> Bool {
        guard
            let payload = decodeJWT(token),
            let exp = payload["exp"] as? TimeInterval
        else {
            return true // If we can't decode, assume it’s invalid
        }
        
        let expireDate = Date(timeIntervalSince1970: exp)
        return Date() >= expireDate
    }
    
    /// Returns the decoded JWT payload (2nd part), or nil if invalid
    private func decodeJWT(_ jwt: String) -> [String: Any]? {
        let segments = jwt.split(separator: ".")
        guard segments.count == 3 else { return nil }
        
        // JWTs use base64URL, so convert to base64
        var base64String = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Pad with trailing '=' if necessary
        while base64String.count % 4 != 0 {
            base64String += "="
        }
        
        guard let data = Data(base64Encoded: base64String) else { return nil }
        
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }
}
