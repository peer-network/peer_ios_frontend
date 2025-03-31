//
//  VideoThumbnail.swift
//  PostCreation
//
//  Created by Артем Васин on 13.02.25.
//

import SwiftUI
import AVKit
import Photos
import DesignSystem

struct VideoThumbnail: View {
    let asset: PHAsset
    @State private var player: AVPlayer? = nil
    @State private var videoRequestID: PHImageRequestID? = nil

    var body: some View {
        ZStack {
            Color.clear

            if let player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
            } else {
                ProgressView()
            }
        }
        .task {
            await loadVideo()
        }
        .onDisappear {
            player?.pause()
            cancelVideoRequest()
        }
    }

    private func loadVideo() async {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true

        cancelVideoRequest()

        await withCheckedContinuation { continuation in
            videoRequestID = manager.requestAVAsset(
                forVideo: asset,
                options: options
            ) { avAsset, _, _ in
                DispatchQueue.main.async {
                    if let avAsset {
                        self.player = AVPlayer(playerItem: AVPlayerItem(asset: avAsset))
                        self.player?.play()
                    }
                    continuation.resume()
                }
            }
        }
    }

    private func cancelVideoRequest() {
        guard let requestID = videoRequestID else { return }
        PHImageManager.default().cancelImageRequest(requestID)
        videoRequestID = nil
    }
}
