//
//  ShortVideoView.swift
//  Post
//
//  Created by Artem Vasin on 07.08.25.
//

import SwiftUI
import AVKit
import DesignSystem
import Environment

private final class PlayerVC: AVPlayerViewController {
    override var prefersStatusBarHidden: Bool { false }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}

private struct CustomVideoPlayer: UIViewControllerRepresentable {
    @Binding var player: AVPlayer?

    func makeUIViewController(context: Context) -> PlayerVC {
        let controller = PlayerVC()
        controller.player = player
        controller.videoGravity = .resizeAspect
        controller.showsPlaybackControls = false
        controller.allowsVideoFrameAnalysis = false
        controller.allowsPictureInPicturePlayback = false
        return controller
    }

    func updateUIViewController(_ uiVC: PlayerVC, context: Context) {
        uiVC.player = player
    }

    static func dismantleUIViewController(_ uiVC: PlayerVC, coordinator: ()) {
        uiVC.player?.pause()
        uiVC.player = nil
    }
}

struct ShortVideoView2: View {
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject var postVM: PostViewModel

    let size: CGSize

    @Binding var showAppleTranslation: Bool

    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @State private var looper: AVPlayerLooper?

    @State private var totalDuration: Double = 0

    @State private var pausedByUser = false

    @State private var showLoadingIndicator: Bool = true
    @State private var show2xSpeedIndicator: Bool = false
    @State private var showBottomSeekerView: Bool = false

    @State private var offsetKeyValue: CGRect = .zero

    // Observers
    @State private var playerTimeObserver: Any?
    @State private var playerStatusObserver: NSKeyValueObservation?

    // Video Seeker Properties
    @GestureState private var isDragging: Bool = false
    @State private var isSeeking: Bool = false
    @State private var progress: CGFloat = 0
    @State private var lastDraggedProgress: CGFloat = 0

    // Video Seeker Thumbnails
    @State private var thumbnailFrames: [UIImage] = []
    @State private var draggingImage: UIImage?
    @State private var thumbnailGenerationTask: Task<(), Never>? = nil

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .scrollView(axis: .vertical))

            ZStack {
                CustomVideoPlayer(player: $player)
                    .preference(key: OffsetKeyRect.self, value: rect)
                    .onPreferenceChange(OffsetKeyRect.self) { value in
                        offsetKeyValue = value
                        playPause(offsetKeyValue)
                    }
                    .pinchZoom()
                    .overlay(alignment: .center) {
                        if showLoadingIndicator {
                            ProgressView()
                                .controlSize(.large)
                        }
                    }
                    .overlay(alignment: .center) {
                        if pausedByUser {
                            pauseIcon
                        } else {
                            if show2xSpeedIndicator {
                                speed2xIndicator
                            }
                        }
                    }
                    .onFirstAppear {
                        setupPlayer()
                    }
                    .onAppear {
                        if player == nil {
                            setupPlayer()
                        }

                        if scenePhase == .active, !pausedByUser {
                            playPause(offsetKeyValue)
                        }
                    }
                    .onDisappear {
                        cleanupPlayer()
                    }
                    .onChange(of: scenePhase) {
                        guard !postVM.showSensitiveContentWarning, !postVM.showIllegalBlur else { return }

                        switch scenePhase {
                            case .active:
                                if !pausedByUser {
                                    player?.play()
                                }
                            default:
                                player?.pause()
                        }
                    }

                Color.clear
                    .contentShape(.rect)
                    .onTapGesture(count: 1) {
                        pausedByUser.toggle()

                        if pausedByUser {
                            player?.pause()
                        } else {
                            player?.play()
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 0) {
                        if !pausedByUser {
                            HapticManager.shared.fireHaptic(.dataRefresh(intensity: 1))
                            show2xSpeedIndicator = true
                            player?.rate = 2
                        }
                    } onPressingChanged: { isPressing in
                        if !pausedByUser {
                            if !isPressing {
                                player?.rate = 1
                                show2xSpeedIndicator = false
                            }
                        }
                    }
                    .doubleTapToLike {
                        try await postVM.like()
                    } onError: { error in
                        if let error = error as? PostActionError {
                            showPopup(
                                text: error.displayMessage,
                                icon: error.displayIcon
                            )
                        } else {
                            showPopup(
                                text: error.userFriendlyDescription
                            )
                        }
                    }
                    .ifCondition(postVM.showSensitiveContentWarning) { // TODO: ADD COVER IMAGE AND BLUR IT HERE BECAUSE OF RERENDERING
                        $0
                            .allowsHitTesting(false)
                            .blur(radius: 25)
                            .overlay {
                                sensitiveContentWarningForVideoPostView
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            }
                            .clipped()
                    }
            }
            .overlay(alignment: .top) {
                PostHeaderView(postVM: postVM, showAppleTranslation: $showAppleTranslation, showFollowButton: true)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .shadow(color: .black, radius: 40, x: 0, y: 0)
            }
            .overlay(alignment: .bottom) {
                if !isSeeking {
                    reelDetailsView()
                }
            }
            .overlay(alignment: .bottom) {
                if showBottomSeekerView {
                    videoSeekerView()
                }
            }
            .overlay(alignment: .bottomLeading) {
                if isDragging, let duration = postVM.post.media.first?.duration {
                    seekerThumbnailView(videoDuration: duration)
                }
            }
            .task {
                try? await postVM.view()
            }
        }
        .statusBar(hidden: false)
        .background(Colors.black)
    }

    private func setupPlayer() {
        guard let videoURL = postVM.post.mediaURLs.first else { return }

        playerItem = AVPlayerItem(url: videoURL)
        playerItem?.preferredForwardBufferDuration = 10.0
        playerItem?.preferredPeakBitRate = 2000000

        totalDuration = playerItem?.duration.seconds ?? 0

        guard let playerItem else { return }

        let queue = AVQueuePlayer(playerItem: playerItem)
        looper = AVPlayerLooper(player: queue, templateItem: playerItem)

        player = queue

        playerStatusObserver = player?.observe(\.status, options: .new) { player, _ in
            if player.status == .readyToPlay {
                showLoadingIndicator = false

                let dur = player.currentItem?.duration.seconds ?? .nan
                if dur.isFinite {
                    self.totalDuration = dur
                    self.checkSeekability()
                    self.addPeriodicTimeObserver()
                }
            }
        }

    }

    private func cleanupPlayer() {
        player?.pause()

        if let playerTimeObserver {
            player?.removeTimeObserver(playerTimeObserver)
            self.playerTimeObserver = nil
        }

        (player as? AVQueuePlayer)?.removeAllItems()

        playerStatusObserver?.invalidate()
        playerStatusObserver = nil

        looper = nil
        playerItem = nil
        player = nil

        thumbnailGenerationTask?.cancel()
        thumbnailGenerationTask = nil
        draggingImage = nil
        thumbnailFrames.removeAll(keepingCapacity: false)
    }

    private func addPeriodicTimeObserver() {
        guard let player, totalDuration > 0 else { return }

        let interval = CMTime(seconds: 0.01, preferredTimescale: 600)

        playerTimeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { time in
            guard !isSeeking else { return }

            let newProgress = time.seconds / totalDuration

            guard newProgress.isFinite else { return }

            guard abs(newProgress - self.lastDraggedProgress) > 0.001 else { return }

            self.progress = max(0, min(newProgress, 1))
            self.lastDraggedProgress = newProgress
        }
    }

    // MARK: - Play/Pause Logic Based on Offset

    private func playPause(_ rect: CGRect) {
        guard !postVM.showSensitiveContentWarning, !postVM.showIllegalBlur else { return }

        let visibleHeight = max(0, min(rect.height, size.height - rect.minY, rect.maxY))
        let visibilityHeightRatio = max(0, min(visibleHeight / rect.height, 1))

        if visibilityHeightRatio > 0.5 {
            if !pausedByUser {
                player?.play()
            }
        } else {
            if visibilityHeightRatio > 0.01 {
                player?.pause()
            } else {
                player?.pause()
                pausedByUser = false
                player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }

    @ViewBuilder
    private func reelDetailsView() -> some View {
        HStack(alignment: .bottom, spacing: 5) {
            VStack(alignment: .leading, spacing: 10) {
                if AccountManager.shared.isCurrentUser(id: postVM.post.owner.id), postVM.post.visibilityStatus == .hidden {
                    HiddenBadgeView()
                } else if postVM.post.hasActiveReports {
                    ReportedBadgeView()
                }

                PostDescriptionComment(postVM: postVM, isInFeed: false)
            }

            PostActionsView(layout: .vertical, postViewModel: postVM)
                .padding(.bottom, -5)
        }
        .padding(.leading, 20)
        .padding(.trailing, 15)
        .padding(.bottom, 20)
        .shadow(color: .black, radius: 40, x: 0, y: 0)
    }

    @ViewBuilder
    private var pauseIcon: some View {
        Image(systemName: "play.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 56)
            .foregroundStyle(Colors.whitePrimary)
            .opacity(0.75)
            .shadow(color: .black, radius: 40, x: 0, y: 0)
    }

    @ViewBuilder
    private var speed2xIndicator: some View {
        Text("2x")
            .font(.customFont(weight: .extraBold, style: .largeTitle))
            .foregroundStyle(Colors.whitePrimary)
            .opacity(0.75)
            .shadow(color: .black, radius: 40, x: 0, y: 0)
    }

    private struct ReelLike: Identifiable {
        var id: UUID = .init()
        var tappedRect: CGPoint = .zero
        var isAnimated: Bool = false
    }

    // MARK: - Video Seeker View

    @ViewBuilder
    func videoSeekerView() -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(.gray)

            Rectangle()
                .fill(.white)
                .frame(width: max(size.width * progress, 0))
        }
        .frame(height: isDragging ? 10 : 3)
        .opacity(isDragging ? 1 : 0.5)
        .overlay(alignment: .leading) {
            Circle()
                .fill(.white)
                .frame(width: 15, height: 15)
            // Showing Drag Knob Only When Dragging
                .scaleEffect(isDragging ? 1 : 0.001, anchor: .init(x: progress, y: 0.5))
            // For More Dragging Space
                .frame(width: 75, height: 75)
                .contentShape(.rect)
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

                            guard !thumbnailFrames.isEmpty else { return }

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
                            let seekTime = CMTime(seconds: totalDuration * progress, preferredTimescale: 600)
                            player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                            isSeeking = false
                        }
                )
                .offset(x: -15 / 2)
                .frame(width: 15, height: 15)
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    // MARK: - Dragging Thumbnail View

    @ViewBuilder
    func seekerThumbnailView(videoDuration: TimeInterval) -> some View {
        let thumbSize: CGSize = .init(width: size.width / 5, height: size.height / 5)
        ZStack {
            if let draggingImage {
                Image(uiImage: draggingImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(.white, lineWidth: 2)
                    }
                    .overlay(alignment: .bottom) {
                        Text(CMTime(seconds: progress * videoDuration, preferredTimescale: 600).toTimeString())
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .offset(y: 25)
                    }
            } else {
                Text(CMTime(seconds: progress * videoDuration, preferredTimescale: 600).toTimeString())
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                //                    .offset(y: thumbSize.height)
            }
        }
//        .offset(y: -60)
        .shadow(color: .black, radius: 40, x: 0, y: 0)
        .frame(width: thumbSize.width, height: thumbSize.height)
        .opacity(isDragging ? 1 : 0)
        // Moving Along side with Gesture
        // Adding Some Padding at Start and End
        .offset(x: progress * (size.width - thumbSize.width - 20))
        .offset(x: 10)
    }

    // MARK: - Generating Thumbnail Frames

    func generateThumbnailFrames(for videoURL: URL, duration: TimeInterval) {
        thumbnailGenerationTask?.cancel()

        thumbnailGenerationTask = Task.detached(priority: .high) {
            let asset = AVURLAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 200, height: 200)
            generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 600)
            generator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 600)

            do {
                let framesPerSecond: Double = 1
                let step = 1.0 / framesPerSecond
                var times = [NSValue]()

                for currentTime in stride(from: 0.0, through: duration, by: step) {
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
                    }
                }
            } catch {
                print("Thumbnail generation error: \(error.localizedDescription)")
            }
        }
    }

    /* gpt version
     func generateThumbnailFrames(for videoURL: URL, duration: TimeInterval) {
             thumbnailGenerationTask?.cancel()

             thumbnailGenerationTask = Task(priority: .high) { [weak self] in
                 guard let self else { return }
                 let asset = AVURLAsset(url: videoURL)
                 let generator = AVAssetImageGenerator(asset: asset)
                 generator.appliesPreferredTrackTransform = true
                 generator.maximumSize = CGSize(width: 200, height: 200)
                 generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 600)
                 generator.requestedTimeToleranceAfter  = CMTimeMake(value: 1, timescale: 600)

                 let fps: Double = 1
                 let step = 1.0 / fps
                 var times = [NSValue]()
                 for t in stride(from: 0.0, through: duration, by: step) {
                     if Task.isCancelled { return }
                     times.append(NSValue(time: CMTime(seconds: t, preferredTimescale: 600)))
                 }

                 let frames: [UIImage] = await withCheckedContinuation { continuation in
                     var generated = [UIImage]()
                     generated.reserveCapacity(times.count)
                     var remaining = times.count
                     var resumed = false

                     generator.generateCGImagesAsynchronously(forTimes: times) { _, cgImage, _, _, error in
                         if Task.isCancelled { return }
                         if let cg = cgImage, error == nil {
                             generated.append(UIImage(cgImage: cg))
                         }
                         remaining -= 1
                         if remaining == 0 && !resumed {
                             resumed = true
                             continuation.resume(returning: generated)
                         }
                     }
                 }

                 if Task.isCancelled { return }
                 if !frames.isEmpty {
                     self.thumbnailFrames = frames
                 }
             }
         }
     */

    private func checkSeekability() {
        guard let item = playerItem else {
            showBottomSeekerView = false
            return
        }

        // Convert each NSValue → CMTimeRange
        let ranges: [CMTimeRange] = item.seekableTimeRanges
          .compactMap { ($0 as? NSValue)?.timeRangeValue }

        // If it’s empty, assume remote VOD is fully seekable
        guard !ranges.isEmpty else {
          showBottomSeekerView = true
          return
        }

        // Otherwise check the first (and usually only) range
        let full = ranges[0]
        let start = full.start.seconds
        let end   = (full.start + full.duration).seconds

        // Allow a tiny epsilon (10 ms) for rounding
        let eps: Double = 0.01
        let coversFromZero = abs(start - 0.0) < eps
        let coversToEnd    = abs(end   - totalDuration) < eps

        showBottomSeekerView = (coversFromZero && coversToEnd)
    }

    private var sensitiveContentWarningForVideoPostView: some View {
        VStack(spacing: 0) {
            Circle()
                .frame(height: 50)
                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                .overlay {
                    IconsNew.eyeWithSlash
                        .iconSize(height: 27)
                        .foregroundStyle(Colors.whitePrimary)
                }
                .padding(.bottom, 14.02)

            Text("Sensitive content")
                .appFont(.largeTitleBold)

            Text("This content may be sensitive or abusive.\nDo you want to view it anyway?")
                .appFont(.bodyRegular)
                .padding(.bottom, 10)

            let showButtonConfig = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "View content")
            StateButton(config: showButtonConfig) {
                withAnimation {
                    postVM.showSensitiveContentWarning = false
                }
                playPause(offsetKeyValue)
            }
            .fixedSize()
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(Colors.whitePrimary)
    }
}
