//
//  MediaUIShareLink.swift
//  MediaUI
//
//  Created by Артем Васин on 10.01.25.
//

import SwiftUI
import Models
import DesignSystem

struct MediaUIShareLink: View {
    let data: MediaData

    public var body: some View {
        Group {
            if data.type == .image {
                let transferable = MediaUIImageTransferable(url: data.url)
                ShareLink(
                    item: transferable,
                    preview: .init(
                        "Share this image",
                        image: transferable
                    )
                )
            } else {
                ShareLink(item: data.url)
            }
        }
        .foregroundStyle(Colors.whitePrimary)
    }
}
