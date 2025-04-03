//
//  PostAudioView.swift
//  FeedNew
//
//  Created by Артем Васин on 06.02.25.
//

import SwiftUI
import DesignSystem
import Environment

struct PostAudioView: View {
    @EnvironmentObject private var audioManager: AudioSessionManager
    @EnvironmentObject private var postVM: PostViewModel

    @State private var progress: CGFloat = 0
    @State private var duration: TimeInterval = 0
    @State private var isActive: Bool = false

    @State private var playClicked: Bool = false

    private var isCurrentPlayingPost: Bool {
        audioManager.currentPlayerObject?.url == postVM.post.mediaURLs.first
    }

    var body: some View {
        if
            let audioURL = postVM.post.mediaURLs.first,
            let timeInterval = postVM.post.media.first?.duration
        {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    let config: WaveformScrubber.Config = .init()

                    WaveformScrubber(config: config, url: audioURL, progress: $progress, playClicked: $playClicked) { info in
                        duration = info.duration
                    } onGestureActive: { status in
                        isActive = status
                        handleScrubbing(status)
                    } onGestureEnded: {
                        if isCurrentPlayingPost {
                            let seekTime = duration * Double(progress)
                            if isCurrentPlayingPost {
                                audioManager.seek(to: seekTime)
                                audioManager.play()
                            }
                        } else {
                            playClicked = true
                            let audioItem = AudioSessionManager.PlayerObject(
                                title: postVM.post.owner.username,
                                subtitle: postVM.post.title,
                                pictureURL: postVM.post.owner.imageURL,
                                url: postVM.post.mediaURLs.first!
                            )
                            audioManager.start(item: audioItem)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                let seekTime = duration * Double(progress)
                                audioManager.seek(to: seekTime)
                            }
                        }

                    }
                    .frame(height: 60)
                    .scaleEffect(y: isActive ? 0.9 : 0.7, anchor: .center)
                    .animation(.bouncy, value: isActive)
                    .frame(width: getRect().width - 20 - 60 - 6)
                    .id(audioURL.absoluteString)

                    playButtonView()
                }

                HStack {
                    Text(current)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: progress)

                    Spacer(minLength: 0)

                    Text(end)
                }
                .monospaced()
                .font(.system(size: 14))
                .foregroundStyle(.gray)
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
            }
            .onAppear {
                duration = timeInterval

                if isCurrentPlayingPost {
                    updateProgressFromAudioManager()
                }
            }
            .onChange(of: isCurrentPlayingPost) {
                if isCurrentPlayingPost {
                    updateProgressFromAudioManager()
                } else {
                    // Reset progress only if not the current post
                    progress = 0
                }
            }
            .onReceive(audioManager.$currentPlayerObject) { playerObject in
                // Reset when current audio changes or stops
                if playerObject?.url != postVM.post.mediaURLs.first {
                    resetProgressIfNotCurrent()
                }
            }
            .onReceive(audioManager.$currentTime) { _ in
                if isCurrentPlayingPost && !isActive {
                    updateProgressFromAudioManager()
                }
            }
        }
    }

    private func resetProgressIfNotCurrent() {
        if !isCurrentPlayingPost {
            progress = 0
            isActive = false
        }
    }

    private func handleScrubbing(_ isScrubbing: Bool) {
        if isScrubbing {
            // Pause playback while scrubbing
            if isCurrentPlayingPost {
                audioManager.pause()
            }
        }
    }

    private func updateProgressFromAudioManager() {
        guard duration > 0 else { return }
        progress = min(Double(audioManager.currentTime) / duration, 1)
    }

    private var current: String {
        let minutes = Int(duration * progress) / 60
        let seconds = Int(duration * progress) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }

    private var end: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }

    private func playButtonView() -> some View {
        Button {
            if isCurrentPlayingPost {
                audioManager.togglePlayPause()
            } else {
                playClicked = true

                let audioItem = AudioSessionManager.PlayerObject(title: postVM.post.owner.username, subtitle: postVM.post.title, pictureURL: postVM.post.owner.imageURL, url: postVM.post.mediaURLs.first!)

                audioManager.start(item: audioItem)
            }
        } label: {
            Circle()
                .strokeBorder(lineWidth: 2)
                .frame(height: 60)
                .overlay {
                    if isCurrentPlayingPost, audioManager.isPlaying {
                        Icons.pause
                            .iconSize(height: 20)
                    } else {
                        Icons.play
                            .iconSize(height: 20)
                    }
                }
                .foregroundStyle(isCurrentPlayingPost ? Color.hashtag : Color.white)
        }
    }
}

#Preview {
    PostAudioView()
        .environmentObject(PostViewModel(post: .placeholderText()))
}
