//
//  MediaUIAttachmentImageView.swift
//  MediaUI
//
//  Created by Артем Васин on 10.01.25.
//

import SwiftUI
import Models
import NukeUI
import SFSafeSymbols

public struct MediaUIAttachmentImageView: View {
    public let data: MediaData
    
    @GestureState private var zoom = 1.0
    
    public var body: some View {
        MediaUIZoomableContainer {
            LazyImage(url: data.url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .scaledToFit()
                        .padding(.horizontal, 8)
                        .scaleEffect(zoom)
                } else if state.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                }
            }
            .draggable(MediaUIImageTransferable(url: data.url))
            .contextMenu {
                MediaUIShareLink(data: data)
                Button {
                    Task {
                        let transferable = MediaUIImageTransferable(url: data.url)
                        UIPasteboard.general.image = UIImage(data: await transferable.fetchData())
                    }
                } label: {
                    Label("Copy Image", systemSymbol: .docOnDoc)
                }
                Button {
                    UIPasteboard.general.url = data.url
                } label: {
                    Label("Copy Link", systemSymbol: .link)
                }
            }
        }
    }
}
