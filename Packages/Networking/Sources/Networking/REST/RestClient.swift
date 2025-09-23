//
//  RestClient.swift
//  Networking
//
//  Created by Artem Vasin on 22.09.25.
//

import Foundation
import TokenKeychainManager
import Apollo
import GQLOperationsGuest

// MARK: - Errors

public enum RestError: Error {
    case invalidURL
    case noData
    case http(status: Int, body: Data?)
    case decoding(Error)
    case transport(Error)
    case unauthorized // 401 after attempted refresh
}

extension RestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .noData: return "Empty response."
        case .http(let status, _): return "HTTP error \(status)."
        case .decoding(let err): return "Decoding failed: \(err.localizedDescription)"
        case .transport(let err): return "Network error: \(err.localizedDescription)"
        case .unauthorized: return "Unauthorized."
        }
    }
}

// MARK: - Token provider mirroring Apollo interceptor

public protocol AccessTokenProvider {
    func validAccessToken() async throws -> String?
}

/// Reuses TokenKeychainManager + RefreshTokenMutation, same logic as your AuthorizationInterceptor.
public final class DefaultAccessTokenProvider: AccessTokenProvider {
    public init() {}

    public func validAccessToken() async throws -> String? {
        // No token
        guard let access = TokenKeychainManager.shared.getAccessToken() else { return nil }

        // Not expired
        if !TokenKeychainManager.shared.isAccessTokenExpired {
            return access
        }

        // Try refresh
        guard
            let refresh = TokenKeychainManager.shared.getRefreshToken(),
            !TokenKeychainManager.shared.isRefreshTokenExpired
        else {
            TokenKeychainManager.shared.removeCredentials()
            return nil
        }

        // Mirror your interceptor behavior
        TokenKeychainManager.shared.removeCredentials()

        do {
            let result = try await GQLClient.shared.mutate(
                mutation: RefreshTokenMutation(refreshToken: refresh)
            )

            guard
                let newAccess = result.refreshToken.accessToken,
                let newRefresh = result.refreshToken.refreshToken
            else {
                throw RestError.unauthorized
            }

            TokenKeychainManager.shared.setCredentials(accessToken: newAccess, refreshToken: newRefresh)
            return newAccess
        } catch {
            throw RestError.transport(error)
        }
    }
}

// MARK: - Multipart descriptors

public struct MultipartPart {
    public let name: String           // e.g. "file[]"
    public let filename: String?      // e.g. "image_00.jpeg"
    public let mimeType: String?      // e.g. "image/jpeg"
    public let data: Data

    public init(name: String, filename: String? = nil, mimeType: String? = nil, data: Data) {
        self.name = name
        self.filename = filename
        self.mimeType = mimeType
        self.data = data
    }
}

// MARK: - Client

public final class RestClient {
    public static let shared = RestClient()

    private let session: URLSession
    private let tokenProvider: AccessTokenProvider

    /// Set this at app start: `RestClient.shared.baseURL = URL(string: "...")!`
    public var baseURL: URL?

    public init(
        session: URLSession = .shared,
        tokenProvider: AccessTokenProvider = DefaultAccessTokenProvider()
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
    }

    // MARK: Optional JSON helper

    public func requestJSON<T: Decodable>(
        _ method: String = "GET",
        path: String,
        query: [String: String?] = [:],
        body: Encodable? = nil,
        headers: [String: String] = [:],
        authorized: Bool = true,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let (request, _) = try await makeRequest(
            method: method,
            path: path,
            query: query,
            headers: headers,
            authorized: authorized,
            bodyData: body.map { try JSONEncoder().encode(AnyEncodable($0)) },
            contentType: body == nil ? nil : "application/json"
        )

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw RestError.noData }

        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw RestError.unauthorized }
            throw RestError.http(status: http.statusCode, body: data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw RestError.decoding(error)
        }
    }

    // MARK: Multipart upload

    public func uploadMultipart(
        path: String,
        query: [String: String?] = [:],
        fields: [String: String] = [:], // form fields
        parts: [MultipartPart],         // files (order preserved)
        headers: [String: String] = [:],
        authorized: Bool = true
    ) async throws -> Data {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        // fields
        for (key, value) in fields {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        // files (order preserved)
        for part in parts {
            body.appendString("--\(boundary)\r\n")
            if let filename = part.filename {
                body.appendString("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(filename)\"\r\n")
            } else {
                body.appendString("Content-Disposition: form-data; name=\"\(part.name)\"\r\n")
            }
            if let mime = part.mimeType {
                body.appendString("Content-Type: \(mime)\r\n")
            }
            body.appendString("\r\n")
            body.append(part.data)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")

        let (request, _) = try await makeRequest(
            method: "POST",
            path: path,
            query: query,
            headers: headers.merging(["Content-Type": "multipart/form-data; boundary=\(boundary)"], uniquingKeysWith: { $1 }),
            authorized: authorized,
            bodyData: body,
            contentType: nil // already set above
        )

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw RestError.noData }

        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw RestError.unauthorized }
            throw RestError.http(status: http.statusCode, body: data)
        }

        return data
    }

    // MARK: private

    private func makeRequest(
        method: String,
        path: String,
        query: [String: String?],
        headers: [String: String],
        authorized: Bool,
        bodyData: Data?,
        contentType: String?
    ) async throws -> (URLRequest, URL) {
        guard let base = baseURL else { throw RestError.invalidURL }
        var url = base.appendingPathComponent(path)
        if !query.isEmpty {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            comps.queryItems = query.compactMap { key, value in value.map { URLQueryItem(name: key, value: $0) } }
            if let u = comps.url { url = u }
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        if let contentType { request.setValue(contentType, forHTTPHeaderField: "Content-Type") }

        if authorized {
            if let token = try await tokenProvider.validAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        request.httpBody = bodyData
        return (request, url)
    }
}

// MARK: - Small utils

private struct AnyEncodable: Encodable {
    let base: Encodable
    init(_ base: Encodable) { self.base = base }
    func encode(to encoder: Encoder) throws { try base.encode(to: encoder) }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
