//
//  PostCreationViewModel.swift
//  PostCreation
//
//  Created by Артем Васин on 11.02.25.
//

import SwiftUI
import Photos
import Models
import DesignSystem
import Networking
import GQLOperationsUser
import Photos
import Environment

@MainActor
final class PostCreationViewModel: NSObject, ObservableObject {
    @Published var isCreatingPost: Bool = false
    @Published var messageToShow = ""

    enum VideoPostType {
        case none
        case short
        case shortAndLong
    }

    enum ShortAndLongVideoSelection {
        case short
        case long
    }

    @Published var selectedType: Post.ContentType = .image
    @Published var selectedVideoType: VideoPostType = .none
    @Published var currentShortAndLongVideoSelection: ShortAndLongVideoSelection = .short

    @Published var allMediaSelected: Bool = false

    // text

    @Published var postTitle: String = ""
    @Published var postText = NSMutableAttributedString(string: "") {
        didSet {
            let range = selectedRange
            processText()
            textView?.attributedText = postText
            selectedRange = range
        }
    }

    @Published var textView: UITextView? {
        didSet {
            textView?.pasteDelegate = self
        }
    }

    var selectedRange: NSRange {
        get {
            guard let textView else {
                return .init(location: 0, length: 0)
            }
            return textView.selectedRange
        }
        set {
            textView?.selectedRange = newValue
        }
    }

    var markedTextRange: UITextRange? {
        guard let textView else {
            return nil
        }
        return textView.markedTextRange
    }

    private var tagsRanges: [NSRange] = []
    private var tags: [String] = []

    var postTextCharacterLength: Int {
        postText.string.utf8.count
    }

    var canPost: Bool {
        postTitle.count > 2 && postTitle.count < 63
    }

    private func processText() {
        guard markedTextRange == nil else { return }
        postText.addAttributes(
            [
                .foregroundColor: UIColor(Colors.whitePrimary),
                .font: UIFont(name: FontType.poppins.name + FontWeight.regular.name, size: 14)!,
                .backgroundColor: UIColor.clear,
                .underlineColor: UIColor.clear,
            ],
            range: NSMakeRange(0, postText.string.utf16.count))
        let hashtagPattern = "#[\\w_]{3,50}"
        let urlPattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"

        do {
            let hashtagRegex = try NSRegularExpression(pattern: hashtagPattern, options: [])
            let urlRegex = try NSRegularExpression(pattern: urlPattern, options: [])

            let range = NSMakeRange(0, postText.string.utf16.count)
            let ranges = hashtagRegex.matches(
                in: postText.string,
                options: [],
                range: range
            ).map(\.range)

            tagsRanges = ranges

            let urlRanges = urlRegex.matches(
                in: postText.string,
                options: [],
                range: range
            ).map(\.range)

            for nsRange in ranges {
                postText.addAttributes(
                    [.foregroundColor: UIColor(Colors.hashtag)],
                    range: nsRange)
            }

            for range in urlRanges {

                postText.addAttributes(
                    [
                        .foregroundColor: UIColor(Colors.hashtag),
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .underlineColor: UIColor(Colors.hashtag),
                    ],
                    range: NSRange(location: range.location, length: range.length))
            }

            postText.enumerateAttributes(in: range) { attributes, range, _ in
                if attributes[.link] != nil {
                    postText.removeAttribute(.link, range: range)
                }
            }
        } catch {}
    }

    private func parseTags() {
        tags = []
        for nsRange in tagsRanges {
            if let range = Range(nsRange, in: postText.string) {
                var tag = String(postText.string[range])
                tag.remove(at: tag.startIndex)
                tags.append(tag)
            }
        }
        print(tags)
    }

    func makePost() async -> Bool {
        parseTags()
        isCreatingPost = true
        do {
            let base64String = Data(postText.string.utf8).base64EncodedString()
            let base64TextString = "data:text/plain;base64,\(base64String)"
            let media = GraphQLNullable<[String]>.some([base64TextString])

            let result = try await GQLClient.shared.mutate(mutation: CreatePostMutation(contenttype: .case(.text), title: postTitle.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "\\\""), media: media, mediadescription: GraphQLNullable(stringLiteral: postText.string), tags: GraphQLNullable<[String]>.some(tags), cover: nil))
            isCreatingPost = false

            guard result.createPost.status == "success" else {
                return false
            }

            return true
        } catch {
            print(error)
            print(error.localizedDescription)
            isCreatingPost = false
            return false
        }
    }

    func makePost(photos: [PHAsset]) async -> Bool {
        parseTags()
        isCreatingPost = true
        do {
            let base64Images = await convertAndCompressImagesToBase64(assets: photos)
            let media = GraphQLNullable<[String]>.some(base64Images)

            let result = try await GQLClient.shared.mutate(mutation: CreatePostMutation(contenttype: .case(.image), title: postTitle.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "\\\""), media: media, mediadescription: GraphQLNullable(stringLiteral: postText.string), tags: GraphQLNullable<[String]>.some(tags), cover: nil))

            isCreatingPost = false

            guard result.createPost.status == "success" else {
                return false
            }

            return true
        } catch {
            print(error)
            print(error.localizedDescription)
            isCreatingPost = false

            return false
        }
    }

    func makePost(shortVideoURL: URL?, longVideoURL: URL?) async -> Bool {
        parseTags()
        isCreatingPost = true
        do {
            if selectedVideoType == .short {
                let shortVideoData = try Data(contentsOf: shortVideoURL!)

                let base64StringshortVideoData = shortVideoData.base64EncodedString()
                let base64VideoStringshortVideoData = "data:video/mp4;base64,\(base64StringshortVideoData)"
                let media = GraphQLNullable<[String]>.some([base64VideoStringshortVideoData])

                let result = try await GQLClient.shared.mutate(mutation: CreatePostMutation(contenttype: .case(.video), title: postTitle.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "\\\""), media: media, mediadescription: GraphQLNullable(stringLiteral: postText.string), tags: GraphQLNullable<[String]>.some(tags), cover: nil))

                isCreatingPost = false
                selectedType = .image

                guard result.createPost.status == "success" else {
                    return false
                }

                return true
            } else {
                let longVideoData = try Data(contentsOf: longVideoURL!)
                let shortVideoData = try Data(contentsOf: shortVideoURL!)

                let base64StringlongVideoData = longVideoData.base64EncodedString()
                let base64VideoStringlongVideoData = "data:video/mp4;base64,\(base64StringlongVideoData)"

                let base64StringshortVideoData = shortVideoData.base64EncodedString()
                let base64VideoStringshortVideoData = "data:video/mp4;base64,\(base64StringshortVideoData)"

                let media = GraphQLNullable<[String]>.some([base64VideoStringshortVideoData, base64VideoStringlongVideoData])

                let result = try await GQLClient.shared.mutate(mutation: CreatePostMutation(contenttype: .case(.video), title: postTitle.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "\\\""), media: media, mediadescription: GraphQLNullable(stringLiteral: postText.string), tags: GraphQLNullable<[String]>.some(tags), cover: nil))

                dump(result)
                isCreatingPost = false
                selectedType = .image

                guard result.createPost.status == "success" else {
                    return false
                }

                return true
            }
        } catch {
            print(error)
            print(error.localizedDescription)
            isCreatingPost = false
            return false
        }
    }

    func makeAudioPost(audio: URL, cover: UIImage?) async -> Bool {
        parseTags()
        isCreatingPost = true

        var coverString = ""

        if
            let cover,
            let compressedImageData = try? await Compressor.shared.compressImageForUpload(cover)
        {
            coverString = "data:image/jpeg;base64,\(compressedImageData.base64EncodedString())"
        }

        do {
            let mp3Data = try Data(contentsOf: audio)
            let mp3Base64 = "data:audio/mpeg;base64,\(mp3Data.base64EncodedString())"

            let media = GraphQLNullable<[String]>.some([mp3Base64])
            let cover = coverString.isEmpty ? nil : GraphQLNullable<[String]>.some([coverString])

            let result = try await GQLClient.shared.mutate(mutation: CreatePostMutation(contenttype: .case(.audio), title: postTitle.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "\\\""), media: media, mediadescription: GraphQLNullable(stringLiteral: postText.string), tags: GraphQLNullable<[String]>.some(tags), cover: cover))

            isCreatingPost = false

            guard result.createPost.status == "success" else {
                return false
            }

            return true
        } catch {
            print(error)
            print(error.localizedDescription)
            isCreatingPost = false

            return false
        }
    }

    private func convertAndCompressImagesToBase64(assets: [PHAsset]) async -> [String] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false  // Async processing
        requestOptions.deliveryMode = .highQualityFormat

        return await withTaskGroup(of: String?.self) { group in
            var base64Strings: [String] = []

            for asset in assets {
                group.addTask {
                    return await self.fetchCompressedBase64(from: asset, imageManager: imageManager, options: requestOptions)
                }
            }

            for await base64String in group {
                if let base64String {
                    base64Strings.append("data:image/jpeg;base64,\(base64String)")
                }
            }

            return base64Strings
        }
    }

    private func fetchCompressedBase64(from asset: PHAsset, imageManager: PHImageManager, options: PHImageRequestOptions) async -> String? {
        guard let uiImage = await fetchUIImage(from: asset, imageManager: imageManager, options: options) else {
            return nil
        }

        if let compressedImageData = try? await Compressor.shared.compressImageForUpload(uiImage) {
            return compressedImageData.base64EncodedString()
        }

        return nil
    }

    private func fetchUIImage(from asset: PHAsset, imageManager: PHImageManager, options: PHImageRequestOptions) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 2000, height: 2000), contentMode: .aspectFit, options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

extension PostCreationViewModel: UITextPasteDelegate {
}
