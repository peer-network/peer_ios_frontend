//
//  PhotoThumbnail.swift
//  PostCreation
//
//  Created by Артем Васин on 11.02.25.
//

import SwiftUI
import Photos
import DesignSystem

struct PhotoThumbnail: View {
    let asset: PHAsset
    let size: CGSize
    @State private var image: UIImage? = nil

    var body: some View {
        ZStack {
            Color.clear

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .controlSize(.extraLarge)
            }
        }
        .task {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        manager.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            if let result {
                self.image = result
            }
        }
    }
}
