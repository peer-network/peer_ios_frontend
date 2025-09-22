//
//  UploadAPI.swift
//  Networking
//
//  Created by Artem Vasin on 22.09.25.
//

//import Foundation
//import UIKit
//
//public enum UploadMedia {
//    case data(Data, filename: String, mime: String)
//    case fileURL(URL, filename: String, mime: String)
//}
//
//public protocol PostMediaUploader {
//    /// Uploads files with eligibilityToken and returns the backend's comma-separated IDs string, e.g. "id1.jpeg,id2.jpeg"
//    func uploadPostMedia(eligibilityToken: String, files: [UploadMedia]) async throws -> String
//}
//
//public final class DefaultPostMediaUploader: PostMediaUploader {
//    public init() {}
//
//    public func uploadPostMedia(eligibilityToken: String, files: [UploadMedia]) async throws -> String {
//        let parts: [MultipartPart] = try files.map { media in
//            switch media {
//            case .data(let data, let filename, let mime):
//                return MultipartPart(name: "file[]", filename: filename, mimeType: mime, data: data)
//            case .fileURL(let url, let filename, let mime):
//                let data = try Data(contentsOf: url)
//                return MultipartPart(name: "file[]", filename: filename, mimeType: mime, data: data)
//            }
//        }
//
//        let data = try await RestClient.shared.uploadMultipart(
//            path: "/post", // <-- adjust to your REST path
//            fields: ["eligibilityToken": eligibilityToken],
//            parts: parts,
//            authorized: true
//        )
//
//        guard let str = String(data: data, encoding: .utf8), !str.isEmpty else {
//            throw RestError.noData
//        }
//        return str
//    }
//}
