//
//  SelectedVideoView.swift
//  PostCreation
//
//  Created by Artem Vasin on 28.05.25.
//

import SwiftUI
import DesignSystem
import AVKit

struct SelectedVideoView: View {
    @Binding var videoWithState: VideoState?
    @Binding var showTrimmingView: Bool
    let onDismiss: () -> Void

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showThumbnail = true
    @State private var playerObserver: NSObjectProtocol?

    @State private var editedVideoURL: URL?
    @State private var editedVideoDuration: Double?

    var body: some View {
        pageContentView
            .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 7)
            .overlay(alignment: .top) {
                if !showTrimmingView {
                    HStack {
                        Button {
                            showThumbnail = false
                            showTrimmingView = true
                        } label: {
                            Image(systemName: "crop")
                                .font(.footnote)
                                .foregroundStyle(Colors.whitePrimary)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Button {
                            cleanUpPlayer()
                            onDismiss()
                            withAnimation {
                                showTrimmingView = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.footnote)
                                .foregroundStyle(Colors.whitePrimary)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(8)
                    .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 4)
                }
            }
            .onDisappear {
                cleanUpPlayer()
                withAnimation {
                    showTrimmingView = false
                }
            }
            .onChange(of: editedVideoURL) {
                guard let editedVideoURL else { return }
                cleanUpPlayer()
                player = AVPlayer(url: editedVideoURL)
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
                try? AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
                setupPlayerObserver()
                player?.seek(to: .zero)
                isPlaying = false
                player?.pause()
            }
    }

    @ViewBuilder
    private var pageContentView: some View {
        if let videoWithState {
            switch videoWithState.state {
                case .loading:
                    ProgressView()
                        .controlSize(.large)
                        .frame(width: getRect().width * 0.654, height: getRect().height * 0.425)
                        .background(Colors.inactiveDark)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                case .loaded(let thumbnail, let videoURL, let duration):
                    videoLoadedView(thumbnail: thumbnail, videoURL: editedVideoURL ?? videoURL, duration: editedVideoDuration ?? duration)
                        .onAppear {
                            self.player = AVPlayer(url: videoURL)
                            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
                            try? AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
                            setupPlayerObserver()
                        }
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func videoLoadedView(thumbnail: Image, videoURL: URL, duration: Double?) -> some View {
        VStack(spacing: 0) {
            if let player, !showThumbnail {
                CustomVideoPlayer(player: player)
                    .frame(width: getRect().width * 0.654, height: getRect().height * 0.425)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay {
                        if showTrimmingView {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Colors.whitePrimary, style: .init(lineWidth: 3, lineCap: .round, dash: [6, 10]))
                        }
                    }
                    .overlay(alignment: .bottom) {
                        HStack(spacing: 0) {
                            VideoDurationView(duration: duration)
                                .padding(12)

                            Spacer()
                                .frame(maxWidth: .infinity)

                            HStack(spacing: 0) {
                                Button {
                                    showThumbnail = true
                                    isPlaying = false
                                    player.pause()
                                    player.seek(to: .zero)
                                } label: {
                                    Image(systemName: "backward.end.fill")
                                        .frame(height: 19)
                                        .foregroundStyle(Colors.whitePrimary)
                                        .padding(12)
                                        .contentShape(.rect)
                                }

                                Button {
                                    if !isPlaying {
                                        isPlaying = true
                                        player.play()
                                    } else {
                                        isPlaying = false
                                        player.pause()
                                    }
                                } label: {
                                    Group {
                                        if !isPlaying {
                                            Icons.play
                                                .iconSize(height: 19)
                                                .foregroundStyle(Colors.whitePrimary)
                                        } else {
                                            Icons.pause
                                                .iconSize(height: 19)
                                                .foregroundStyle(Colors.whitePrimary)
                                        }
                                    }
                                    .padding(12)
                                    .contentShape(.rect)
                                }
                            }
                        }
                    }
            } else {
                thumbnailView(thumbnail: thumbnail, videoURL: videoURL, duration: duration)
                    .frame(width: getRect().width * 0.654, height: getRect().height * 0.425)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            if showTrimmingView {
                VideoTrimmerView(player: $player, isPlaying: $isPlaying, videoDuration: duration ?? 0, url: videoURL, minimumDurationInSeconds: 5, maximumDurationInSeconds: nil, seekerTint: Colors.whitePrimary, indicatorTint: Colors.whitePrimary, quality: .custom, outputFileType: .mp4) { url, duration, error in
                    showThumbnail = true
                    if let error {
                        showPopup(text: error.userFriendlyDescription)
                    }
                    if let url, let duration {
                        editedVideoDuration = duration
                        editedVideoURL = url
                        self.videoWithState = .init(id: UUID().uuidString, state: .loaded(thumbnail: thumbnail, videoURL: url, duration: duration))
                    }
                    showTrimmingView = false
                } onClose: {
                    showTrimmingView = false
                }
            }
        }
    }

    private func thumbnailView(thumbnail: Image, videoURL: URL, duration: Double?) -> some View {
        ZStack(alignment: .bottom) {
            thumbnail
                .resizable()
                .scaledToFill()
                .frame(width: getRect().width * 0.654, height: getRect().height * 0.425)
                .clipped()

            HStack(spacing: 0) {
                VideoDurationView(duration: duration)

                Spacer()

                Button {
                    isPlaying = true
                    player?.play()
                    showThumbnail = false
                } label: {
                    Icons.play
                        .iconSize(height: 19)
                        .foregroundStyle(Colors.whitePrimary)
                        .contentShape(.rect)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }

    private func setupPlayerObserver() {
        // Remove previous observer if exists
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        // Add new observer for playback end
        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main) { [weak player] _ in
                withAnimation {
                    if !showTrimmingView {
                        isPlaying = false
                        player?.seek(to: .zero)
                        player?.pause()
                    }
                }
            }
    }

    private func cleanUpPlayer() {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
            playerObserver = nil
        }
        player?.pause()
        player = nil
        isPlaying = false
    }
}

fileprivate struct CustomVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill
        controller.showsPlaybackControls = false
        controller.allowsVideoFrameAnalysis = false
        controller.allowsPictureInPicturePlayback = false

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

fileprivate struct VideoDurationView: View {
    private let durationString: String

    init(duration: Double?) {
        let seconds = duration ?? 0
        self.durationString = VideoDurationView.formatDuration(seconds)
    }

    var body: some View {
        Text(durationString)
            .font(.customFont(style: .footnote))
            .foregroundStyle(Colors.whitePrimary)
    }

    private static func formatDuration(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? ""
    }
}
