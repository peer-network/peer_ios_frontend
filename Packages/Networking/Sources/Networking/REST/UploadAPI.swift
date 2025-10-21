//
//  UploadAPI.swift
//  Networking
//
//  Created by Artem Vasin on 22.09.25.
//

import Foundation
import UIKit
import Models

public enum UploadMedia {
    case data(Data, filename: String, mime: String)
    case fileURL(URL, filename: String, mime: String)
}

public protocol PostMediaUploader {
    /// Uploads files with eligibilityToken and returns the backend's *uploadedFiles* string, e.g. "id1.jpeg,id2.jpeg"
    func uploadPostMedia(eligibilityToken: String, files: [UploadMedia]) async throws -> String
}

// MARK: - Response model

private struct UploadResponse: Decodable {
    let status: String
    let responseCode: String
    let uploadedFiles: String?

    enum CodingKeys: String, CodingKey {
        case status
        case responseCode = "ResponseCode"
        case uploadedFiles
    }
}

public enum UploadParseError: Error, LocalizedError {
    case emptyResponse
    case decodingFailed
    case backendRejected(status: String, code: String)
    case missingUploadedFiles

    public var errorDescription: String? {
        switch self {
            case .emptyResponse: return "Upload returned an empty response."
            case .decodingFailed: return "Failed to decode upload response."
            case .backendRejected(let status, let code):
                let message = ErrorCodeManager.shared.getUserFriendlyMessage(for: code)
                return message
                //            return "Upload failed (\(status ?? "unknown")). Code: \(code ?? "N/A")."
            case .missingUploadedFiles: return "Upload succeeded but file IDs are missing."
        }
    }
}

// MARK: - Uploader

public final class DefaultPostMediaUploader: PostMediaUploader {
    public init() {}

    public func uploadPostMedia(eligibilityToken: String, files: [UploadMedia]) async throws -> String {
        let parts: [MultipartPart] = try files.map { media in
            switch media {
            case .data(let d, let filename, let mime):
                return MultipartPart(name: "file[]", filename: filename, mimeType: mime, data: d)

            case .fileURL(let url, let filename, let mime):
                let fileData = try Data(contentsOf: url)
                return MultipartPart(name: "file[]", filename: filename, mimeType: mime, data: fileData)
            }
        }

        let data = try await RestClient.shared.uploadMultipart(
            path: "/upload-post",
            fields: ["eligibilityToken": eligibilityToken],
            parts: parts,
            authorized: true
        )

        guard !data.isEmpty else { throw UploadParseError.emptyResponse }

        // Try to decode JSON: { "status": "success", "ResponseCode": "11515", "uploadedFiles": "id1.jpg,id2.jpg" }
        let decoder = JSONDecoder()
        if let resp = try? decoder.decode(UploadResponse.self, from: data) {
            // Check status
            let ok = resp.status.lowercased()
            if ok != "success" {
                throw UploadParseError.backendRejected(status: resp.status, code: resp.responseCode)
            }
            guard let files = resp.uploadedFiles, !files.isEmpty else {
                throw UploadParseError.missingUploadedFiles
            }
            return files
        }

        // If server ever returns a raw string (legacy), fall back to that:
        if let str = String(data: data, encoding: .utf8), !str.isEmpty, str.first != "{" {
            return str
        }

        throw UploadParseError.decodingFailed
    }
}
