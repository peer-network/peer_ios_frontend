//
//  PostShareLinkView.swift
//  PeerApp
//
//  Created by Artem Vasin on 18.08.25.
//

import SwiftUI
import Models
import DesignSystem

struct PostShareLinkView<ButtonView: View>: View {
    private let post: Post
    private let sharePreview: SharePreviewProtocol?

    @ViewBuilder private let buttonView: ButtonView

    init(post: Post, @ViewBuilder buttonView: @escaping () -> ButtonView) {
        self.buttonView = buttonView()

        self.post = post

        let title = "Post from @\(post.owner.username)"

        let imageURL: URL? = {
            switch post.contentType {
                case .text:
                    return nil
                case .image:
                    return post.mediaURLs.first
                case .video, .audio:
                    return post.coverURL
            }
        }()

        if let imageURL {
            let imageTransferable = PostImageTransferable(url: imageURL)
            self.sharePreview = .image(SharePreview(title, image: imageTransferable))
        } else {
            self.sharePreview = .text(SharePreview(title))
        }
    }

    var body: some View {
        if let shareURL = post.shareURL {
            if case let .image(p)? = sharePreview {
                ShareLink(item: shareURL, preview: p) { buttonView.allowsHitTesting(false) }
            } else if case let .text(p)? = sharePreview {
                ShareLink(item: shareURL, preview: p) { buttonView.allowsHitTesting(false) }
            } else {
                ShareLink(item: shareURL) { buttonView.allowsHitTesting(false) }
            }
        }
    }
}

private enum SharePreviewProtocol {
    case image(SharePreview<PostImageTransferable, Never>)
    case text(SharePreview<Never, Never>)
}

private struct PostImageTransferable: Codable, Transferable {
    let url: URL

    func fetchData() async -> Data {
        do {
            return try await URLSession.shared.data(from: url).0
        } catch {
            return Data()
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { transferable in
            await transferable.fetchData()
        }
    }
}
