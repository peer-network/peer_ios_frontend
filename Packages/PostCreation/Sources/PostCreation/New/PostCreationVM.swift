//
//  PostCreationVM.swift
//  PostCreation
//
//  Created by Artem Vasin on 01.06.25.
//

import SwiftUI
import GQLOperationsUser
import Environment
import Models

@MainActor
final class PostCreationVM: ObservableObject {
    public unowned var apiService: APIService!
    public unowned var accountManager: AccountManager!

    @Published private(set) var isLoading: Bool = false
    @Published var error = ""

    func makePhotoPost(title: String, description: String, images: [UIImage], hashtags: [String]) async -> Bool {
        withAnimation {
            error = ""
            isLoading = true
        }

        let isFreePost = takeFreePost()

        do {
            let fixedTitle = trimWhitespaces(from: title)
            let fixedDescription = trimWhitespaces(from: description)

            var compressedImages: [String] = []

            // Process images in order
            for image in images {
                let compressedImageData = try await Compressor.shared.compressImageForUpload(image)
                var base64String = compressedImageData.base64EncodedString()
                addBase64Prefix(to: &base64String, ofType: .photo)
                compressedImages.append(base64String)
            }

            let result = await apiService.makePost(
                of: .image,
                with: fixedTitle,
                content: compressedImages,
                contentDescitpion: fixedDescription,
                tags: hashtags,
                cover: nil
            )

            isLoading = false

            switch result {
            case .success:
                return true
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            withAnimation {
                self.error = error.userFriendlyDescription
            }
            if isFreePost {
                returnFreePost()
            }
            return false
        }
    }

    func makeTextPost(title: String, description: String, hashtags: [String]) async -> Bool {
        withAnimation {
            error = ""
            isLoading = true
        }

        let isFreePost = takeFreePost()

        do {
            let fixedTitle = trimWhitespaces(from: title)

            let fixedDescription = trimWhitespaces(from: description)
            var encodedDescription = Data(fixedDescription.utf8).base64EncodedString()
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
            case .success:
                return true
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            withAnimation {
                self.error = error.userFriendlyDescription
            }
            if isFreePost {
                returnFreePost()
            }
            return false
        }
    }

    func makeVideoPost(title: String, description: String, hashtags: [String], videoURL: URL) async -> Bool {
        withAnimation {
            error = ""
            isLoading = true
        }

        let isFreePost = takeFreePost()

        do {
            let fixedTitle = trimWhitespaces(from: title)
            let fixedDescription = trimWhitespaces(from: description)

            let videoData = try Data(contentsOf: videoURL)
            var base64VideoData = videoData.base64EncodedString()
            addBase64Prefix(to: &base64VideoData, ofType: .video)

            let result = await apiService.makePost(
                of: .video,
                with: fixedTitle,
                content: [base64VideoData],
                contentDescitpion: fixedDescription,
                tags: hashtags,
                cover: nil
            )

            isLoading = false

            switch result {
            case .success:
                return true
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            withAnimation {
                self.error = error.userFriendlyDescription
            }
            if isFreePost {
                returnFreePost()
            }
            return false
        }
    }

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
                case .text: return "data:text/plain;base64,"
            }
        }()

        content.insert(contentsOf: prefix, at: content.startIndex)
    }
}
