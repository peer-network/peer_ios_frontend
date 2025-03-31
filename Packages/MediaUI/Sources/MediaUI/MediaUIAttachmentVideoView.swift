//
//  MediaUIAttachmentVideoView.swift
//  MediaUI
//
//  Created by Артем Васин on 10.01.25.
//

import SwiftUI
import AVKit
import Environment
import DesignSystem
import SFSafeSymbols

@MainActor
public class MediaUIAttachmentVideoViewModel: ObservableObject {
    @Published var player: AVPlayer?
    let url: URL
    let forceAutoPlay: Bool
    @Published var isPlaying: Bool = false
    
    public init(url: URL, forceAutoPlay: Bool = false) {
        self.url = url
        self.forceAutoPlay = forceAutoPlay
    }
    
    func preparePlayer(autoPlay: Bool) {
        player = .init(url: url)
        player?.audiovisualBackgroundPlaybackPolicy = .pauses
        player?.preventsDisplaySleepDuringVideoPlayback = false
        if autoPlay || forceAutoPlay {
            player?.play()
            isPlaying = true
        } else {
            player?.pause()
            isPlaying = false
        }
        guard let player else { return }
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem, queue: .main
        ) { _ in
            Task { @MainActor [weak self] in
                if autoPlay || self?.forceAutoPlay == true {
                    self?.play()
                }
            }
        }
    }
    
    func mute(_ mute: Bool) {
        player?.isMuted = mute
    }
    
    func pause() {
        isPlaying = false
        player?.pause()
    }
    
    func stop() {
        isPlaying = false
        player?.pause()
        player = nil
    }
    
    func play() {
        isPlaying = true
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    
    func resume() {
        isPlaying = true
        player?.play()
    }
    
    func preventSleep(_ preventSleep: Bool) {
        player?.preventsDisplaySleepDuringVideoPlayback = preventSleep
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

public struct MediaUIAttachmentVideoView: View {
    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var userPreferences: UserPreferences
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var viewModel: MediaUIAttachmentVideoViewModel
    @State private var isFullScreen: Bool = false
    
    public init(viewModel: MediaUIAttachmentVideoViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            CustomVideoPlayer(player: $viewModel.player)
            
            if !userPreferences.autoPlayVideo,
               !viewModel.forceAutoPlay,
               !isFullScreen,
               !viewModel.isPlaying
            {
                Button(
                    action: {
                        viewModel.play()
                    },
                    label: {
                        Image(systemSymbol: .playFill)
                            .font(.largeTitle)
                            .foregroundColor(theme.tintColor)
                            .padding(theme.postMediaStyle == .compact ? 0 : 10)
                            .background(Circle().fill(.thinMaterial))
                    }
                )
            }
        }
        .overlay(content: {
            HStack {}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !userPreferences.autoPlayVideo && !viewModel.isPlaying {
                        viewModel.play()
                        return
                    }
                    isFullScreen = true
                }
        })
        .onAppear {
            viewModel.preparePlayer(autoPlay: isFullScreen ? true : userPreferences.autoPlayVideo)
            viewModel.mute(userPreferences.muteVideo)
        }
        .onDisappear {
            viewModel.stop()
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            modalPreview
        }
        .cornerRadius(4)
        .onChange(of: scenePhase) {
            switch scenePhase {
                case .background, .inactive:
                    viewModel.pause()
                case .active:
                    if userPreferences.autoPlayVideo || viewModel.forceAutoPlay || isFullScreen {
                        viewModel.play()
                    }
                default:
                    break
            }
        }
    }
    
    private var modalPreview: some View {
        NavigationStack {
            VideoPlayer(
                player: viewModel.player,
                videoOverlay: {
                    if !userPreferences.autoPlayVideo,
                       !viewModel.forceAutoPlay,
                       !isFullScreen,
                       !viewModel.isPlaying
                    {
                        Button {
                            viewModel.play()
                        } label: {
                            Image(systemSymbol: .playFill)
                                .font(.largeTitle)
                                .foregroundColor(theme.tintColor)
                                .padding(theme.postMediaStyle == .compact ? 0 : 10)
                        }
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isFullScreen.toggle()
                    } label: {
                        Image(systemSymbol: .xmarkCircle)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.global().async {
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                try? AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)
                try? AVAudioSession.sharedInstance().setActive(true)
            }
            viewModel.preventSleep(true)
            viewModel.mute(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !userPreferences.autoPlayVideo {
                    viewModel.play()
                } else {
                    viewModel.resume()
                }
            }
        }
        .onDisappear {
            if !userPreferences.autoPlayVideo {
                viewModel.pause()
            }
            viewModel.preventSleep(false)
            viewModel.mute(userPreferences.muteVideo)
            DispatchQueue.global().async {
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
                try? AVAudioSession.sharedInstance().setActive(true)
            }
        }
    }
}


private struct CustomVideoPlayer: UIViewControllerRepresentable {
    @Binding var player: AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill
        controller.showsPlaybackControls = false
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Updating Player
        uiViewController.player = player
    }
}
