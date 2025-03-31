//
//  VideoConfirmationView.swift
//  PostCreation
//
//  Created by Artem Vasin on 05.03.25.
//

import SwiftUI
import Photos
import AVKit

struct VideoConfirmationView: View {
    let asset: PHAsset
    let onTrimmedVideo: (AVAsset) -> Void

    @State private var player: AVPlayer? = nil
    @State private var videoRequestID: PHImageRequestID? = nil

    @State private var trimStartTime: Double = 0
    @State private var trimEndTime: Double = 30

    var body: some View {
        ZStack {
            Color.clear

            if let player {
                VideoPlayer(player: player)
                    .disabled(true)
                    .onAppear {
                        player.play()
                        loopVideoInTrimRange()
                    }
            } else {
                ProgressView()
            }

            VStack {
                TrimmingOverlayView(
                    trimStartTime: $trimStartTime,
                    trimEndTime: $trimEndTime,
                    videoDuration: asset.duration
                )
                .frame(height: 60)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            VStack(spacing: 10) {
                Text("\(asset.duration.stringFromTimeInterval())")
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                HStack(spacing: 10) {
                    changeButton

                    nextButton
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(10)
        }
        .cornerRadius(24)
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

    private func trimVideoAndPassBack() {
        guard let avAsset = player?.currentItem?.asset else { return }

        let startTime = CMTime(seconds: trimStartTime, preferredTimescale: 600)
        let endTime = CMTime(seconds: trimEndTime, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startTime, end: endTime)

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("trimmedVideo.mp4")

        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputURL = outputURL
        exportSession?.outputFileType = .mp4
        exportSession?.timeRange = timeRange

        exportSession?.exportAsynchronously {
            if exportSession?.status == .completed {
                DispatchQueue.main.async {
                    let trimmedAsset = AVAsset(url: outputURL)
                    onTrimmedVideo(trimmedAsset)  // Pass the trimmed video back
                }
            }
        }
    }

    private var changeButton: some View {
        Button {
            //
        } label: {
            HStack(spacing: 0) {
                Text("Change")
                Spacer()
                Text("x")
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(
                Color.white.opacity(0.01)
                    .blur(radius: 22.6)
            )
            .cornerRadius(24)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.white, lineWidth: 1)
            }
            .frame(maxWidth: .infinity)
        }
        .shadow(color: .black.opacity(0.5), radius: 25, x: 0, y: 4)
    }

    private var nextButton: some View {
        Button {
            trimVideoAndPassBack()
        } label: {
            HStack(spacing: 0) {
                Text("Next")
                Spacer()
                Text("x")
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(.black.opacity(0.2))
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.47, green: 0.69, blue: 1), location: 0.00),
                        Gradient.Stop(color: Color(red: 0, green: 0.41, blue: 1), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0, y: 0.5),
                    endPoint: UnitPoint(x: 1, y: 0.5)
                )
            )
            .cornerRadius(24)
            .frame(maxWidth: .infinity)
        }
        .shadow(color: .black.opacity(0.5), radius: 25, x: 0, y: 4)
    }

    private func loopVideoInTrimRange() {
        guard let player else { return }
        player.seek(to: CMTime(seconds: trimStartTime, preferredTimescale: 600))

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: CMTime(seconds: trimStartTime, preferredTimescale: 600))
            player.play()
        }
    }

}

