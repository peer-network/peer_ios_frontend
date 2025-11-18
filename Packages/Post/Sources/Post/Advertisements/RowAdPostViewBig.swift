//
//  RowAdPostViewBig.swift
//  Post
//
//  Created by Artem Vasin on 04.11.25.
//

import SwiftUI
import DesignSystem
import Models
import NukeUI

public struct RowAdPostViewBig: View {
    @StateObject private var postVM: PostViewModel

    private let adStats: SingleAdStats
    private let showDates: Bool

    public init(adStats: SingleAdStats, showDates: Bool) {
        _postVM = .init(wrappedValue: .init(post: adStats.post))
        self.adStats = adStats
        self.showDates = showDates
    }

    private var mediaURL: URL? {
        if postVM.post.contentType == .image {
            return postVM.post.mediaURLs.first!
        } else {
            return postVM.post.coverURL ?? nil
        }
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            let imageWidth = (getRect().width - 20 * 3) * 0.3
            let imageHeight = imageWidth * 0.83

            LazyImage(url: mediaURL) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: imageWidth,
                            height: imageHeight
                        )
                        .clipShape(Rectangle())
                        .allowsHitTesting(false)
                } else {
                    Colors.blackDark
                }
            }
            .frame(width: imageWidth, height: imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay {
                contentTypeIcon
            }
            .overlay(alignment: .topLeading) {
                PinIndicatorViewSmall()
                    .padding(5)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(postVM.post.title)
                    .appFont(.smallLabelBold)
                    .lineLimit(1)

                if !postVM.post.media.isEmpty, let text = postVM.attributedDescription {
                    Text(text)
                        .appFont(.smallLabelRegular)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
                    .frame(minHeight: 2)
                    .frame(maxHeight: .infinity)
                    .layoutPriority(-1)

                HStack(spacing: 0) {
                    if
                        showDates,
                        let startText = convertUTCToLocalDate(adStats.startDate),
                        let endText = convertUTCToLocalDate(adStats.endDate)
                    {
                        Text("\(startText) - \(endText)")
                            .appFont(.smallLabelRegular)
                            .foregroundStyle(Colors.whiteSecondary)
                            .lineLimit(1)

                        Spacer()
                            .frame(minWidth: 5)
                            .frame(maxWidth: .infinity)
                            .layoutPriority(-1)
                    }

                    HStack(spacing: 3) {
                        Circle()
                            .frame(width: 5)

                        Text(isEarlierThanCurrentUTC(adStats.endDate) ? "Ended" : "Active")
                            .appFont(.init(weight: .regular, size: .dummyDesignSystem))
                            .lineLimit(1)
                    }
                    .foregroundStyle(isEarlierThanCurrentUTC(adStats.endDate) ? Colors.redAccent : Colors.passwordBarsGreen)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Colors.blackDark)
                    }
                }
            }
            .frame(height: imageHeight)
        }
        .foregroundStyle(Colors.whitePrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private var contentTypeIcon: some View {
        Group {
            switch postVM.post.contentType {
                case .text:
                    Icons.a
                        .iconSize(height: 24)
                case .image:
                    Icons.camera
                        .iconSize(height: 24)
                case .video:
                    Icons.play
                        .iconSize(height: 24)
                case .audio:
                    Icons.musicBars
                        .iconSize(height: 24)
            }
        }
    }

    private struct PinIndicatorViewSmall: View {
        var body: some View {
            Icons.pin
                .iconSize(height: 15)
                .foregroundStyle(Colors.whitePrimary)
                .padding(7.5)
                .background {
                    Circle()
                        .foregroundStyle(Colors.version)
                }
        }
    }

    private func convertUTCToLocalDate(_ utcDateString: String) -> String? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        guard let date = dateFormatter.date(from: utcDateString) else {
            return nil
        }

        dateFormatter.dateFormat = "d MMM yyyy"
        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.string(from: date)
    }

    private func isEarlierThanCurrentUTC(_ utcDateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        guard let date = dateFormatter.date(from: utcDateString) else {
            return false
        }

        return date < Date()
    }
}
