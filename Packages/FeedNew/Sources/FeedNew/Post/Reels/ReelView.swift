//
//  ReelView.swift
//  FeedNew
//
//  Created by Артем Васин on 07.02.25.
//

import SwiftUI
import AVKit
import DesignSystem
import Models
import Environment

private struct CustomVideoPlayer: UIViewControllerRepresentable {
    @Binding var player: AVPlayer?

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

struct ReelView: View {
    @SwiftUI.Environment(\.scenePhase) private var scenePhase

    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var postVM: PostViewModel

    @Binding var likedCounter: [ReelLike]

    let size: CGSize

    @State private var player: AVPlayer?
    @State private var looper: AVPlayerLooper?

    @State private var pausedByUser = false

    // Video Seeker Properties
    @GestureState private var isDragging: Bool = false
    @State private var isSeeking: Bool = false
    @State private var progress: CGFloat = 0
    @State private var lastDraggedProgress: CGFloat = 0
    @State private var observer: Any?

    // Video Seeker Thumbnails
    @State private var thumbnailFrames: [UIImage] = []
    @State private var draggingImage: UIImage?
    @State private var playerStatusObserver: NSKeyValueObservation?
    @State private var thumbnailGenerationTask: Task<(), Never>? = nil

    @State private var showAppleTranslation: Bool = false
    @State private var showReportAlert: Bool = false
    @State private var showBlockAlert: Bool = false

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .scrollView(axis: .vertical))

            CustomVideoPlayer(player: $player)
            // Offset Updates
                .preference(key: OffsetKeyRect.self, value: rect)
                .onPreferenceChange(OffsetKeyRect.self) { value in
                    playPause(value)
                }
                .overlay(alignment: .top) {
                    PostHeaderView()
                        .environment(\.isBackgroundWhite, false)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                }
                .overlay(alignment: .bottom) {
                    if !isSeeking {
                        ReelDetailsView()
                    }
                }
                .overlay(alignment: .center) {
                    if pausedByUser {
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 56)
                            .foregroundStyle(.white)
                            .opacity(0.75)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    SeekerThumbnailView()
                        .offset(y: -60)
                }
                .overlay(alignment: .bottom) {
                    VideoSeekerView()
                }
            // Double Tap for Like Animation
                .onTapGesture(count: 2) { position in
                    let id = UUID()
                    likedCounter.append(.init(id: id, tappedRect: position, isAnimated: false))
                    withAnimation(.snappy(duration: 1.0), completionCriteria: .logicallyComplete) {
                        if let index = likedCounter.firstIndex(where: { $0.id == id }) {
                            likedCounter[index].isAnimated = true
                        }
                    } completion: {
                        likedCounter.removeAll(where: { $0.id == id })
                    }
                    Task {
                        do {
                            HapticManager.shared.fireHaptic(.notification(.success))
                            try await postVM.toggleLike()
                            showPopup(
                                text: "You used 1 like! Free likes left for today: \(AccountManager.shared.dailyFreeLikes)",
                                icon: Icons.heartFill
                                //.foregroundStyle(Colors.redAccent)
                            )
                        } catch let error as PostActionError {
                            showPopup(
                                text: error.displayMessage,
                                icon: error.displayIcon
                            )
                        }
                    }
                }
                .onTapGesture(count: 1) {
                    pausedByUser.toggle()
                    if pausedByUser {
                        player?.pause()
                    } else {
                        player?.play()
                    }
                }
            // Creating Player
                .onAppear {
                    postVM.apiService = apiManager.apiService

                    setupPlayer()

                    if scenePhase == .active && !pausedByUser {
                        player?.play()
                    }
                }
            // Clearing Player
                .onDisappear {
                    cleanupPlayer()
                }
                .onChange(of: scenePhase) {
                    switch scenePhase {
                        case .active:
                            if !pausedByUser {
                                player?.play()
                            }
                        default:
                            player?.pause()
                    }
                }
        }
        .task {
            try? await postVM.toggleView()
        }
        .alert(
            isPresented: $showReportAlert,
            content: {
                Alert(
                    title: Text("Confirm"),
                    message: Text("Are you sure you want to report this post?"),
                    primaryButton: .destructive(
                        Text("Report")
                    ) {
                        Task {
                            do {
                                try await postVM.toggleReport()
                                showPopup(text: "Post was reported.")
                            } catch let error as PostActionError {
                                showPopup(
                                    text: error.displayMessage,
                                    icon: error.displayIcon
                                )
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        )
#if canImport(_Translation_SwiftUI)
        .addTranslateView(
            isPresented: $showAppleTranslation, text: "\(postVM.post.title)\n\n\(postVM.post.mediaDescription)")
#endif
    }

    private func setupPlayer() {
        guard let videoURL = postVM.post.mediaURLs.first else { return }

        cleanupPlayer()

        let playerItem = AVPlayerItem(url: videoURL)
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        playerItem.preferredForwardBufferDuration = TimeInterval(1)

        let queue = AVQueuePlayer(playerItem: playerItem)
        looper = AVPlayerLooper(player: queue, templateItem: playerItem)

        player = queue

        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)

        //        player?.audiovisualBackgroundPlaybackPolicy = .pauses use it instead of scenePhases?

        // Periodic observer for progress update
        observer = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 600), queue: .main) { [weak player] time in
            guard let player = player else { return }

            if !isSeeking {
                let totalDuration = playerItem.duration.seconds
                let currentDuration = player.currentTime().seconds
                let calculatedProgress = currentDuration / totalDuration

                progress = calculatedProgress
                lastDraggedProgress = progress
            }
        }

        // Player status observer to generate thumbnails when player is ready
        playerStatusObserver = player?.observe(\.status, options: .new) { player, _ in
            if player.status == .readyToPlay && thumbnailFrames.isEmpty {
                generateThumbnailFrames()
            }
        }

        player?.playImmediately(atRate: 1.0)
    }

    private func cleanupPlayer() {
        pausedByUser = false

        thumbnailGenerationTask?.cancel()
        thumbnailGenerationTask = nil
        thumbnailFrames.removeAll()
        draggingImage = nil

        player?.pause()
        player?.replaceCurrentItem(with: nil)

        playerStatusObserver?.invalidate()
        playerStatusObserver = nil

        if let observer {
            player?.removeTimeObserver(observer)
            self.observer = nil
        }

        looper = nil
        player = nil
    }

    // MARK: - Play/Pause Logic Based on Offset

    private func playPause(_ rect: CGRect) {
        if !pausedByUser {
            if -rect.minY < (rect.height * 0.5) && rect.minY < (rect.height * 0.5) {
                player?.play()
            } else {
                player?.pause()
            }
        }

        if rect.minY >= size.height || -rect.minY >= size.height {
            pausedByUser = false
            player?.seek(to: .zero)
        }
    }

    // MARK: - Reel Details & Controls

    @ViewBuilder
    private func ReelDetailsView() -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            PostDescriptionComment(isInFeed: false)
                .environmentObject(postVM)

            PostActionsView(horizontal: false, showAppleTranslation: $showAppleTranslation, showReportAlert: $showReportAlert, showBlockAlert: $showBlockAlert)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .environment(\.isBackgroundWhite, false)
    }

    // MARK: - Video Seeker View

    @ViewBuilder
    func VideoSeekerView() -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(.gray)

            Rectangle()
                .fill(.white)
                .frame(width: max(size.width * progress, 0))
        }
        .frame(height: 3)
        .overlay(alignment: .leading) {
            Circle()
                .fill(.white)
                .frame(width: 15, height: 15)
            // Showing Drag Knob Only When Dragging
                .scaleEffect(isDragging ? 1 : 0.001, anchor: .init(x: progress, y: 0.5))
            // For More Dragging Space
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
            // Moving Along Side With Gesture Progress
                .offset(x: size.width * progress)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { _, out, _ in
                            out = true
                        }
                        .onChanged { value in
                            // Calculating Progress
                            let translationX: CGFloat = value.translation.width
                            let calculatedProgress = (translationX / size.width) + lastDraggedProgress

                            progress = max(min(calculatedProgress, 1), 0)
                            isSeeking = true

                            if thumbnailFrames.isEmpty { return }

                            let dragIndex = Int(round(progress * CGFloat(thumbnailFrames.count - 1)))

                            // Checking if FrameThubmnails Contains the Frame
                            if thumbnailFrames.indices.contains(dragIndex) {
                                draggingImage = thumbnailFrames[dragIndex]
                            }
                        }
                        .onEnded { _ in
                            // Storing Last Known Progress
                            lastDraggedProgress = progress
                            // Seeking Video To Dragged Time
                            if let currentPlayerItem = player?.currentItem {
                                let totalDuration = currentPlayerItem.duration.seconds
                                let seekTime = CMTime(seconds: totalDuration * progress, preferredTimescale: 600)
                                player?.seek(to: seekTime)
                            }

                            isSeeking = false
                        }
                )
                .offset(x: progress * size.width > 15 ? (progress * -15) : 0)
                .frame(width: 15, height: 15)
        }
    }

    // MARK: - Dragging Thumbnail View

    @ViewBuilder
    func SeekerThumbnailView() -> some View {
        let thumbSize: CGSize = .init(width: size.width / 5, height: size.height / 5)
        ZStack {
            if let draggingImage {
                Image(uiImage: draggingImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .bottom) {
                        if let currentItem = player?.currentItem {
                            Text(CMTime(seconds: progress * currentItem.duration.seconds, preferredTimescale: 600).toTimeString())
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .offset(y: 25)
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(.white, lineWidth: 2)
                    }
            } else {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(.white, lineWidth: 2)
                    }
            }
        }
        .frame(width: thumbSize.width, height: thumbSize.height)
        .opacity(isDragging ? 1 : 0)
        // Moving Along side with Gesture
        // Adding Some Padding at Start and End
        .offset(x: progress * (size.width - thumbSize.width - 20))
        .offset(x: 10)
    }

    // MARK: - Generating Thumbnail Frames

    func generateThumbnailFrames() {
        thumbnailGenerationTask?.cancel()

        thumbnailGenerationTask = Task.detached {
            guard let asset = await self.player?.currentItem?.asset else { return }

            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 150, height: 150)
            generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 600)
            generator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 600)

            do {
                let totalDuration = try await asset.load(.duration).seconds
                let framesPerSecond: Double = 1
                let step = 1.0 / framesPerSecond
                var times = [NSValue]()

                for currentTime in stride(from: 0.0, through: totalDuration, by: step) {
                    try Task.checkCancellation()
                    let cmTime = CMTime(seconds: currentTime, preferredTimescale: 600)
                    times.append(NSValue(time: cmTime))
                }

                let frames = await withCheckedContinuation { continuation in
                    var generatedFrames = [UIImage]()
                    generatedFrames.reserveCapacity(times.count)

                    var remainingCount = times.count

                    generator.generateCGImagesAsynchronously(forTimes: times) { requestedTime, cgImage, _, _, error in
                        autoreleasepool {
                            if Task.isCancelled { return }

                            if let cgImage = cgImage, error == nil {
                                generatedFrames.append(UIImage(cgImage: cgImage))
                            }

                            remainingCount -= 1
                            if remainingCount == 0 {
                                continuation.resume(returning: generatedFrames)
                            }
                        }
                    }
                }

                if !Task.isCancelled && !frames.isEmpty {
                    await MainActor.run {
                        self.thumbnailFrames = frames
                        print("Generated \(frames.count) thumbnails")
                    }
                }
            } catch {
                print("Thumbnail generation error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ReelsMainView()
        .environmentObject(PostViewModel(post: .placeholderText()))
        .environmentObject(APIServiceManager(.mock))
}
