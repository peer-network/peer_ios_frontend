//
//  SelectedAudioView.swift
//  PostCreation
//
//  Created by Artem Vasin on 04.06.25.
//

import SwiftUI
import DesignSystem
import Environment
import Post
import AVFoundation

struct SelectedAudioView: View {
    @EnvironmentObject private var audioManager: AudioSessionManager
    @EnvironmentObject private var accountManager: AccountManager

    @Binding var audioState: AudioState?

    // Audio Player properties
    @State private var playClicked: Bool = false
    @State private var progress: CGFloat = 0
    @State private var duration: TimeInterval = 0
    @State private var isActive: Bool = false

    private var isCurrentPlaying: Bool {
        audioManager.currentPlayerObject?.url == audioState?.url
    }

    private var coverImageBinding: Binding<ImageState?> {
        Binding<ImageState?>(
            get: { audioState?.cover },
            set: { newValue in
                audioState?.cover = newValue
            }
        )
    }

    var body: some View {
        if let audioState {
            VStack(spacing: 24) {
                chooseBackgroundButton

                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        audioView(audioState: audioState)

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
            }
            .padding(20)
            .background {
                if let cover = audioState.cover, case .loaded(let image) = cover.state {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .overlay {
                            Gradients.blackHover
                        }
                } else {
                    Colors.inactiveDark
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .onAppear {
                if isCurrentPlaying {
                    updateProgressFromAudioManager()
                }
            }
            .onChange(of: isCurrentPlaying) {
                if isCurrentPlaying {
                    updateProgressFromAudioManager()
                } else {
                    // Reset progress only if not the current post
                    progress = 0
                }
            }
            .onReceive(audioManager.$currentPlayerObject) { playerObject in
                // Reset when current audio changes or stops
                if playerObject?.url != audioState.url {
                    resetProgressIfNotCurrent()
                }
            }
            .onReceive(audioManager.$currentTime) { _ in
                if isCurrentPlaying && !isActive {
                    updateProgressFromAudioManager()
                }
            }
            .onDisappear {
                audioManager.stop()
                resetProgressIfNotCurrent()
            }
        } else {
            EmptyView()
        }
    }

    private var chooseBackgroundButton: some View {
        AudioCoverPicker(imageState: coverImageBinding) {
            HStack(spacing: 0) {
                plusButton

                Spacer(minLength: 20)

                let actionText = audioState?.cover != nil ? "Change" : "Choose"
                Text("\(actionText) background image")
                    .font(.customFont(weight: .regular, style: .body))
                    .foregroundStyle(Colors.whiteSecondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Colors.whiteSecondary, style: .init(lineWidth: 4, lineCap: .round, dash: [8, 10]))
            }
            .contentShape(.rect)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var plusButton: some View {
        Icons.plusBold
            .iconSize(height: 22)
            .foregroundStyle(Colors.whitePrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Gradients.activeButtonBlue, in: Circle())
            .frame(width: 68, height: 68)
    }

    // MARK: - Audio

    private func audioView(audioState: AudioState) -> some View {
        WaveformScrubber(url: audioState.url, progress: $progress, playClicked: $playClicked) { info in
            duration = info.duration
        } onGestureActive: { status in
            isActive = status
            handleScrubbing(status)
        } onGestureEnded: {
            if isCurrentPlaying {
                let seekTime = duration * Double(progress)
                if isCurrentPlaying {
                    audioManager.seek(to: seekTime)
                    audioManager.play()
                }
            } else {
                playClicked = true
                let audioItem = AudioSessionManager.PlayerObject(
                    title: accountManager.user?.username ?? "",
                    subtitle: "Title",
                    pictureURL: accountManager.user?.imageURL,
                    url: audioState.url
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
        .frame(width: getRect().width - 80 - 60 - 6)
    }

    private var current: String {
        guard duration > 0 else { return "" }
        let minutes = Int(duration * progress) / 60
        let seconds = Int(duration * progress) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }

    private var end: String {
        guard duration > 0 else { return "" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }

    private func playButtonView() -> some View {
        Button {
            if isCurrentPlaying {
                audioManager.togglePlayPause()
            } else {
                playClicked = true

                let audioItem = AudioSessionManager.PlayerObject(
                    title: accountManager.user?.username ?? "",
                    subtitle: "Title",
                    pictureURL: accountManager.user?.imageURL,
                    url: audioState!.url
                )

                audioManager.start(item: audioItem)
            }
        } label: {
            Circle()
                .strokeBorder(lineWidth: 2)
                .frame(height: 60)
                .overlay {
                    if isCurrentPlaying, audioManager.isPlaying {
                        Icons.pause
                            .iconSize(height: 20)
                    } else {
                        Icons.play
                            .iconSize(height: 20)
                    }
                }
                .foregroundStyle(isCurrentPlaying ? Colors.hashtag : Colors.whitePrimary)
        }
    }

    private func handleScrubbing(_ isScrubbing: Bool) {
        if isScrubbing {
            // Pause playback while scrubbing
            if isCurrentPlaying {
                audioManager.pause()
            }
        }
    }

    private func updateProgressFromAudioManager() {
        guard duration > 0 else { return }
        progress = min(Double(audioManager.currentTime) / duration, 1)
    }

    private func resetProgressIfNotCurrent() {
        if !isCurrentPlaying {
            progress = 0
            isActive = false
        }
    }
}
