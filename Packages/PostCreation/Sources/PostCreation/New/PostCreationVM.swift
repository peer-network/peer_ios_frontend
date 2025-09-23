//
//  PostCreationVM.swift
//  PostCreation
//
//  Created by Artem Vasin on 01.06.25.
//

//import SwiftUI
//import GQLOperationsUser
//import Environment
//import Models
//import AVFoundation
//
//@MainActor
//final class PostCreationVM: ObservableObject {
//    public unowned var apiService: APIService!
//    public unowned var accountManager: AccountManager!
//
//    @Published private(set) var isLoading: Bool = false
//    @Published var error = ""
//
//    func makePhotoPost(title: String, description: String, images: [UIImage], hashtags: [String]) async -> Bool {
//        withAnimation {
//            error = ""
//            isLoading = true
//        }
//
//        let isFreePost = takeFreePost()
//
//        do {
//            let fixedTitle = trimWhitespaces(from: title)
//            let fixedDescription = trimWhitespaces(from: description)
//
//            var compressedImages: [String] = []
//
//            // Process images in order
//            for image in images {
//                let compressedImageData = try await Compressor.shared.compressImageForUpload(image)
//                var base64String = compressedImageData.base64EncodedString()
//                addBase64Prefix(to: &base64String, ofType: .photo)
//                compressedImages.append(base64String)
//            }
//
//            let result = await apiService.makePost(
//                of: .image,
//                with: fixedTitle,
//                content: compressedImages,
//                contentDescitpion: fixedDescription,
//                tags: hashtags,
//                cover: nil
//            )
//
//            isLoading = false
//
//            switch result {
//            case .success:
//                return true
//            case .failure(let apiError):
//                throw apiError
//            }
//        } catch {
//            withAnimation {
//                self.error = error.userFriendlyDescription
//            }
//            if isFreePost {
//                returnFreePost()
//            }
//            return false
//        }
//    }
//
//    func makeTextPost(title: String, description: String, hashtags: [String]) async -> Bool {
//        withAnimation {
//            error = ""
//            isLoading = true
//        }
//
//        let isFreePost = takeFreePost()
//
//        do {
//            let fixedTitle = trimWhitespaces(from: title)
//
//            let fixedDescription = trimWhitespaces(from: description)
//            var encodedDescription = Data(fixedDescription.utf8).base64EncodedString()
//            addBase64Prefix(to: &encodedDescription, ofType: .text)
//
//            let result = await apiService.makePost(
//                of: .text,
//                with: fixedTitle,
//                content: [encodedDescription],
//                contentDescitpion: "",
//                tags: hashtags,
//                cover: nil
//            )
//
//            isLoading = false
//
//            switch result {
//            case .success:
//                return true
//            case .failure(let apiError):
//                throw apiError
//            }
//        } catch {
//            withAnimation {
//                self.error = error.userFriendlyDescription
//            }
//            if isFreePost {
//                returnFreePost()
//            }
//            return false
//        }
//    }
//
//    func makeVideoPost(title: String, description: String, hashtags: [String], videoURL: URL) async -> Bool {
//        withAnimation {
//            error = ""
//            isLoading = true
//        }
//
//        let isFreePost = takeFreePost()
//
//        do {
//            guard let downsizedURL = try await createDownsizedVideo(url: videoURL) else {
//                if isFreePost {
//                    returnFreePost()
//                }
//                return false
//            }
//
//            let fixedTitle = trimWhitespaces(from: title)
//            let fixedDescription = trimWhitespaces(from: description)
//
//            let videoData = try Data(contentsOf: downsizedURL)
//            var base64VideoData = videoData.base64EncodedString()
//            addBase64Prefix(to: &base64VideoData, ofType: .video)
//
//            let result = await apiService.makePost(
//                of: .video,
//                with: fixedTitle,
//                content: [base64VideoData],
//                contentDescitpion: fixedDescription,
//                tags: hashtags,
//                cover: nil
//            )
//
//            isLoading = false
//
//            switch result {
//            case .success:
//                return true
//            case .failure(let apiError):
//                throw apiError
//            }
//        } catch {
//            withAnimation {
//                self.error = error.userFriendlyDescription
//            }
//            if isFreePost {
//                returnFreePost()
//            }
//            return false
//        }
//    }
//
//    func makeAudioPost(title: String, description: String, hashtags: [String], audioURL: URL, cover coverImage: UIImage?) async -> Bool {
//        withAnimation {
//            error = ""
//            isLoading = true
//        }
//
//        let isFreePost = takeFreePost()
//
//        do {
//            let fixedTitle = trimWhitespaces(from: title)
//            let fixedDescription = trimWhitespaces(from: description)
//
//            let audioData = try Data(contentsOf: audioURL)
//            var base64AudioData = audioData.base64EncodedString()
//            addBase64Prefix(to: &base64AudioData, ofType: .audio)
//
//            var base64CoverString: String?
//
//            if let coverImage {
//                let compressedImageData = try await Compressor.shared.compressImageForUpload(coverImage)
//                var base64 = compressedImageData.base64EncodedString()
//                addBase64Prefix(to: &base64, ofType: .photo)
//                base64CoverString = base64
//            }
//
//            let result = await apiService.makePost(
//                of: .audio,
//                with: fixedTitle,
//                content: [base64AudioData],
//                contentDescitpion: fixedDescription,
//                tags: hashtags,
//                cover: base64CoverString
//            )
//
//            isLoading = false
//
//            switch result {
//            case .success:
//                return true
//            case .failure(let apiError):
//                throw apiError
//            }
//        } catch {
//            withAnimation {
//                self.error = error.userFriendlyDescription
//            }
//            if isFreePost {
//                returnFreePost()
//            }
//            return false
//        }
//    }
//
//    private func takeFreePost() -> Bool {
//        if accountManager.dailyFreePosts > 0 {
//            accountManager.freePostUsed()
//            return true
//        } else {
//            return false
//        }
//    }
//
//    private func returnFreePost() {
//        accountManager.increaseFreePosts()
//    }
//
//    private func trimWhitespaces(from string: String) -> String {
//        string.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//
//    private func addBase64Prefix(to content: inout String, ofType: PostType) {
//        let prefix: String = {
//            switch ofType {
//                case .photo: return "data:image/jpeg;base64,"
//                case .audio: return "data:audio/mpeg;base64,"
//                case .video: return "data:video/mp4;base64,"
//                case .text: return "data:text/plain;base64,"
//            }
//        }()
//
//        content.insert(contentsOf: prefix, at: content.startIndex)
//    }
//
//    private func createDownsizedVideo(url: URL) async throws -> URL? {
//        let outputURL = URL(filePath: NSTemporaryDirectory()).appending(path: "uploading_video_\(UUID().uuidString).\("mp4")")
//
//        /// Removing Existing Item
//        if FileManager.default.fileExists(atPath: outputURL.path()) {
//            try FileManager.default.removeItem(at: outputURL)
//        }
//
//        /// Export Session
//        let asset = AVAsset(url: url)
//        if let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset1920x1080) {
//            session.outputURL = outputURL
//            session.outputFileType = .mp4
//
//            await session.export()
//
//            return outputURL
//        } else {
//            return nil
//        }
//    }
//}


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

    // Inject to allow testing / swapping implementations
    private let uploader: PostMediaUploader

    @Published private(set) var isLoading: Bool = false
    @Published var error = ""

    init(uploader: PostMediaUploader = DefaultPostMediaUploader()) {
        RestClient.shared.baseURL = URL(string: "https://getpeer.eu")!
        self.uploader = uploader
    }

    // MARK: - Public API

    func makePhotoPost(title: String, description: String, images: [UIImage], hashtags: [String]) async -> Bool {
        await createPost(
            type: .image,
            title: title,
            description: description,
            hashtags: hashtags
        ) {
            // Compress concurrently but return in original selection order
            let media: [UploadMedia] = try await images.asyncIndexedMapConcurrentOrdered { index, image in
                let data = try await Compressor.shared.compressImageForUpload(image)
                return UploadMedia.data(data, filename: String(format: "image_%02d.jpeg", index), mime: "image/jpeg")
            }
            return media
        }
    }

    func makeTextPost(title: String, description: String, hashtags: [String]) async -> Bool {
        // Text remains base64 as before (unless your backend changed it)
        withAnimation {
            error = ""
            isLoading = true
        }

        let isFreePost = takeFreePost()

        do {
            let fixedTitle = trimWhitespaces(from: title)
            let fixedDescription = trimWhitespaces(from: description)
            var encodedDescription = Foundation.Data(fixedDescription.utf8).base64EncodedString()
            addBase64Prefix(to: &encodedDescription, ofType: .text)

            let result = await apiService.makePost(
                of: .text,
                with: fixedTitle,
                content: [encodedDescription],
                contentDescitpion: "",
                tags: hashtags,
                cover: nil
            )

            isLoading = false
            switch result {
            case .success: return true
            case .failure(let apiError): throw apiError
            }
        } catch {
            withAnimation { self.error = error.userFriendlyDescription }
            if isFreePost { returnFreePost() }
            return false
        }
    }

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
            return [UploadMedia.fileURL(downsizedURL, filename: "video_00.mp4", mime: "video/mp4")]
        }
    }

    func makeAudioPost(title: String, description: String, hashtags: [String], audioURL: URL, cover coverImage: UIImage?) async -> Bool {
        await createPost(
            type: .audio,
            title: title,
            description: description,
            hashtags: hashtags
        ) {
            var files: [UploadMedia] = [
                UploadMedia.fileURL(audioURL, filename: "audio_00.mp3", mime: "audio/mpeg")
            ]
            if let coverImage {
                let imgData = try await Compressor.shared.compressImageForUpload(coverImage)
                files.append(UploadMedia.data(imgData, filename: "cover_01.jpeg", mime: "image/jpeg"))
            }
            return files
        }
    }

    // MARK: - Shared flow: token -> upload -> makePost

    private func createPost(
        type: ContentType,
        title: String,
        description: String,
        hashtags: [String],
        gatherMedia: @escaping () async throws -> [UploadMedia]
    ) async -> Bool {
        withAnimation {
            error = ""
            isLoading = true
        }

        let isFreePost = takeFreePost()

        do {
            let fixedTitle = trimWhitespaces(from: title)
            let fixedDescription = trimWhitespaces(from: description)

            // 1) Eligibility token via APIService
            let eligibilityToken: String
            switch await apiService.getMediaUploadToken() {
            case .success(let token):
                eligibilityToken = token
            case .failure(let apiError):
                throw apiError
            }

            // 2) Prepare files (ordered)
            let files = try await gatherMedia()
            guard !files.isEmpty else { throw APIError.missingData }

            // 3) Multipart upload (keeps order)
            let idsString = try await uploader.uploadPostMedia(
                eligibilityToken: eligibilityToken,
                files: files
            )

            // 4) Post via GraphQL with IDs string
            // If server expects separate items, split by comma here.
            let result = await apiService.makePostMultipart(
                of: type,
                with: fixedTitle,
                content: idsString, // or idsString.components(separatedBy: ",")
                contentDescitpion: fixedDescription,
                tags: hashtags,
                cover: nil
            )

            isLoading = false
            switch result {
            case .success: return true
            case .failure(let apiError): throw apiError
            }

        } catch {
            withAnimation { self.error = error.userFriendlyDescription }
            if isFreePost { returnFreePost() }
            return false
        }
    }

    // MARK: - Helpers (unchanged)

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
