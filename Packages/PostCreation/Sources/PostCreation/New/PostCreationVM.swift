//
//  PostCreationVM.swift
//  PostCreation
//
//  Created by Artem Vasin on 01.06.25.
//

import SwiftUI
import GQLOperationsUser
import Networking
import Environment
import Models
import AVFoundation

@MainActor
final class PostCreationVM: ObservableObject {
    public unowned var apiService: APIService!
    public unowned var accountManager: AccountManager!
    private let uploader: PostMediaUploader

    @Published private(set) var isLoading: Bool = false
    @Published var error = ""

    init(uploader: PostMediaUploader = DefaultPostMediaUploader()) {
        RestClient.shared.baseURL = URL(string: "https://getpeer.eu")!
        self.uploader = uploader
    }

    // MARK: - PHOTO
    func makePhotoPost(title: String, description: String, images: [UIImage], hashtags: [String]) async -> Bool {
        await createPost(
            type: .image,
            title: title,
            description: description,
            hashtags: hashtags
        ) {
            // Compress concurrently, keep user’s order
            let media: [UploadMedia] = try await images.asyncIndexedMapConcurrentOrdered { index, image in
                let data = try await Compressor.shared.compressImageForUpload(image)
                return UploadMedia.data(
                    data,
                    filename: String(format: "image_%02d.jpeg", index),
                    mime: "image/jpeg"
                )
            }
            return media
        } coverBase64Provider: {
            // Photo post has no cover separate from images
            nil
        }
    }

    // MARK: - TEXT
    func makeTextPost(title: String, description: String, hashtags: [String]) async -> Bool {
        await createPost(
            type: .text,
            title: title,
            description: "",
            hashtags: hashtags
        ) {
            let fixedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
            let data = Data(fixedDescription.utf8)
            return [
                UploadMedia.data(
                    data,
                    filename: "description.txt",
                    mime: "text/plain"
                )
            ]
        } coverBase64Provider: {
            nil
        }
    }

    // MARK: - VIDEO
    func makeVideoPost(title: String, description: String, hashtags: [String], videoURL: URL) async -> Bool {
        await createPost(
            type: .video,
            title: title,
            description: description,
            hashtags: hashtags
        ) { [weak self] in
            guard let self else { return [] }
            guard let downsizedURL = try await self.createDownsizedVideo(url: videoURL) else {
                throw APIError.unknownError(error: RestError.noData)
            }
            let ext = downsizedURL.pathExtension.nonEmpty ?? "mp4"
            let mime = Self.inferMimeType(for: downsizedURL) ?? "video/mp4"
            return [UploadMedia.fileURL(downsizedURL, filename: "video_00.\(ext)", mime: mime)]
        } coverBase64Provider: {
            nil
        }
    }

    // MARK: - AUDIO
    func makeAudioPost(title: String, description: String, hashtags: [String], audioURL: URL, cover coverImage: UIImage?) async -> Bool {
        await createPost(
            type: .audio,
            title: title,
            description: description,
            hashtags: hashtags
        ) {
            let ext = audioURL.pathExtension.nonEmpty ?? "mp3"
            let mime = Self.inferMimeType(for: audioURL) ?? (ext.lowercased() == "wav" ? "audio/wav" : "audio/mpeg")
            return [UploadMedia.fileURL(audioURL, filename: "audio_00.\(ext)", mime: mime)]
        } coverBase64Provider: { [weak self] in
            guard let coverImage, let self else { return nil }
            do {
                let imgData = try await Compressor.shared.compressImageForUpload(coverImage)
                var base64 = imgData.base64EncodedString()
                self.addBase64Prefix(to: &base64, ofType: .photo)
                return base64
            } catch {
                // If cover fails to compress, we proceed without it.
                return nil
            }
        }
    }

    // MARK: - Shared flow: token -> upload -> GraphQL
    private func createPost(
        type: ContentType,
        title: String,
        description: String,
        hashtags: [String],
        gatherMedia: @escaping () async throws -> [UploadMedia],
        coverBase64Provider: @escaping () async -> String?
    ) async -> Bool {
        withAnimation {
            error = ""
            isLoading = true
        }
        let isFreePost = takeFreePost()
        defer { withAnimation { isLoading = false } }

        do {
            let fixedTitle = trimWhitespaces(from: title)
            let fixedDescription = trimWhitespaces(from: description)

            // 1) Token for multipart
            let token: String = try await {
                switch await apiService.getMediaUploadToken() {
                    case .success(let t): return t
                    case .failure(let e): throw e
                }
            }()

            // 2) Prepare files (ordered)
            let files = try await gatherMedia()
            guard !files.isEmpty else { throw APIError.missingData }

            // 3) Upload files (multipart)
            let idsString = try await uploader.uploadPostMedia(eligibilityToken: token, files: files)

            // 4) Cover (audio only)
            let coverBase64 = await coverBase64Provider()

            // 5) GraphQL post (backend expects a single comma-separated string for content)
            let result = await apiService.makePostMultipart(
                of: type,
                with: fixedTitle,
                content: idsString,
                contentDescitpion: fixedDescription,
                tags: hashtags,
                cover: coverBase64
            )

            switch result {
                case .success: return true
                case .failure(let apiError): throw apiError
            }
        } catch {
            self.error = error.userFriendlyDescription
            if isFreePost { returnFreePost() }
            return false
        }
    }

    // MARK: - Helpers
    private func takeFreePost() -> Bool {
        if accountManager.dailyFreePosts > 0 {
            accountManager.freePostUsed()
            return true
        } else {
            return false
        }
    }

    private func returnFreePost() {
        accountManager.increaseFreePosts()
    }

    private func trimWhitespaces(from string: String) -> String {
        string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addBase64Prefix(to content: inout String, ofType: PostType) {
        let prefix: String = {
            switch ofType {
                case .photo: return "data:image/jpeg;base64,"
                case .audio: return "data:audio/mpeg;base64,"
                case .video: return "data:video/mp4;base64,"
                case .text:  return "data:text/plain;base64,"
            }
        }()
        content.insert(contentsOf: prefix, at: content.startIndex)
    }

    private func createDownsizedVideo(url: URL) async throws -> URL? {
        let outputURL = URL(filePath: NSTemporaryDirectory())
            .appending(path: "uploading_video_\(UUID().uuidString).mp4")

        if FileManager.default.fileExists(atPath: outputURL.path()) {
            try FileManager.default.removeItem(at: outputURL)
        }

        let asset = AVAsset(url: url)
        if let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset1920x1080) {
            session.outputURL = outputURL
            session.outputFileType = .mp4
            await session.export()
            return outputURL
        } else {
            return nil
        }
    }

    // Prefer original file MIME when possible
    private static func inferMimeType(for url: URL) -> String? {
        guard let utType = UTType(filenameExtension: url.pathExtension) else { return nil }
        return utType.preferredMIMEType
    }
}

// MARK: - Async map helpers (now on Sequence, with indexed variant)

private extension Sequence {
    /// Serial, preserves order by design.
    func asyncMapSerial<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var results: [T] = []
        for element in self {
            let value = try await transform(element)
            results.append(value)
        }
        return results
    }

    /// Concurrent, preserves order of the original sequence.
    func asyncMapConcurrentOrdered<T>(_ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        let array = Array(self)
        var results = Array<T?>(repeating: nil, count: array.count)

        try await withThrowingTaskGroup(of: (Int, T).self) { group in
            for (i, el) in array.enumerated() {
                group.addTask {
                    let value = try await transform(el)
                    return (i, value)
                }
            }
            for try await (i, value) in group {
                results[i] = value
            }
        }

        // Force unwrap is safe because each index is filled or throws
        return results.map { $0! }
    }

    /// Concurrent, preserves order, and provides the original index to the transform.
    func asyncIndexedMapConcurrentOrdered<T>(_ transform: @escaping (Int, Element) async throws -> T) async rethrows -> [T] {
        let array = Array(self)
        var results = Array<T?>(repeating: nil, count: array.count)

        try await withThrowingTaskGroup(of: (Int, T).self) { group in
            for (i, el) in array.enumerated() {
                group.addTask {
                    let value = try await transform(i, el)
                    return (i, value)
                }
            }
            for try await (i, value) in group {
                results[i] = value
            }
        }

        return results.map { $0! }
    }
}

private extension String {
    /// Returns self if not empty, otherwise nil.
    var nonEmpty: String? { isEmpty ? nil : self }
}
