//
//  MediaUIView.swift
//  MediaUI
//
//  Created by Артем Васин on 10.01.25.
//

import SwiftUI
import SFSafeSymbols
import Nuke
import Models

public struct MediaUIView: View {
    private let data: [MediaData]
    @State private var currentItem: MediaData
    
    public init(data: [MediaData?], initialItem: MediaData) {
        self.data = data.compactMap { $0 }
        self.currentItem = initialItem
    }
    
    public var body: some View {
        NavigationStack {
            TabView(selection: $currentItem) {
                ForEach(data) { item in
                    DisplayView(data: item)
                        .tag(item)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            .toolbar {
                MediaToolBar(data: currentItem)
            }
        }
    }
}

private struct MediaToolBar: ToolbarContent {
    let data: MediaData
    
    var body: some ToolbarContent {
        DismissToolbarItem()
        SavePhotoToolbarItem(data: data)
        ShareToolbarItem(data: data)
    }
}

private struct DismissToolbarItem: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemSymbol: .xmarkCircle)
                    .foregroundStyle(Color.white)
            }
        }
    }
}

private struct SavePhotoToolbarItem: ToolbarContent {
    let data: MediaData
    @State private var state = SavingState.unsaved
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if data.type == .image {
                Button {
                    Task {
                        state = .saving
                        if await saveImage(url: data.url) {
                            withAnimation {
                                state = .saved
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    state = .unsaved
                                }
                            }
                        }
                    }
                } label: {
                    switch state {
                        case .unsaved: Image(systemSymbol: .arrowDownCircle)
                        case .saving: ProgressView()
                        case .saved: Image(systemSymbol: .checkmarkCircleFill)
                    }
                }
                .foregroundStyle(Color.white)
            } else {
                EmptyView()
            }
        }
    }
    
    private enum SavingState {
        case unsaved
        case saving
        case saved
    }
    
    private func imageData(_ url: URL) async -> Data? {
        var data = ImagePipeline.shared.cache.cachedData(for: .init(url: url))
        if data == nil {
            data = try? await URLSession.shared.data(from: url).0
        }
        return data
    }
    
    private func uiimageFor(url: URL) async throws -> UIImage? {
        let data = await imageData(url)
        if let data {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func saveImage(url: URL) async -> Bool {
        if let image = try? await uiimageFor(url: url) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            return true
        }
        return false
    }
}

private struct DisplayView: View {
    let data: MediaData
    
    var body: some View {
        switch data.type {
            case .image:
                MediaUIAttachmentImageView(data: data)
            case .video:
                MediaUIAttachmentVideoView(viewModel: .init(url: data.url, forceAutoPlay: true))
                    .ignoresSafeArea()
                EmptyView()
            case .text, .audio:
                EmptyView()
        }
    }
}
