//
//  VideoView.swift
//  Post
//
//  Created by Artem Vasin on 29.07.25.
//

import SwiftUI
import DesignSystem
import VideoPlayer
import AVKit

struct VideoView: View {
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject var postVM: PostViewModel

    let size: CGSize
    @Binding var showAppleTranslation: Bool

    @State private var play: Bool = false
    @State private var pausedByUser: Bool = false
    @State private var pausedByApp: Bool = false // IMPLEMENT. PAUSE WHEN SWITCHING TABS. AND TAKE A LOOK AT MUSIC PLAYING

    @State private var time: CMTime = .zero
    @State private var totalDuration: Double = 0

    @State private var showLoadingIndicator: Bool = false

    @State private var playSpeedRate: Float = 1

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

    // Like animation
    @State private var likedCounter: [ReelLike] = []

    @State private var offsetKeyValue: CGRect = .zero

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .scrollView(axis: .vertical))

            Group {
                if let videoURL = postVM.post.mediaURLs.first {
                    VideoPlayer(url: videoURL, play: $play, time: $time)
                        .contentMode(postVM.post.media.first!.videoAspectRatio < 0.7813 ? .scaleAspectFill : .scaleAspectFit)
                        .autoReplay(true)
                        .speedRate(playSpeedRate)
                        .onStateChanged { state in
                            print(state)
                            switch state {
                                case .loading:
                                    showLoadingIndicator = true
                                case .playing(let totalDuration):
                                    showLoadingIndicator = false
                                    self.totalDuration = totalDuration
                                case .paused(let playProgress, let bufferProgress):
                                    showLoadingIndicator = false

                                    if thumbnailFrames.isEmpty, let duration = postVM.post.media.first?.duration {
                                        generateThumbnailFrames(for: videoURL, duration: duration)
                                    }
                                case .error(let error):
                                    showLoadingIndicator = false
                                    /*elf.stateText = "Error: \(error)"*/
                            }
                        }
                        .preference(key: OffsetKeyRect.self, value: rect)
                        .onPreferenceChange(OffsetKeyRect.self) { value in
                            offsetKeyValue = value
                            playPause(offsetKeyValue)
                        }
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .overlay(alignment: .center) {
                            if showLoadingIndicator {
                                ProgressView()
                                    .controlSize(.large)
                            }
                        }
                        .overlay(alignment: .center) {
                            if pausedByUser {
                                pauseIcon
                            }
                        }
                        .onTapGesture(count: 1) {
                            pausedByUser.toggle()
                            if pausedByUser {
                                play = false
                            } else {
                                play = true
                            }
                        }
                    // Double tap for liking the video
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
                                    try await postVM.like()
                                } catch {
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
                            }
                        }
//                        .onLongPressGesture(minimumDuration: 1.0, maximumDistance: 0) {
//                            playSpeedRate = 2
//                            print("Started")
//                        } onPressingChanged: { pressing in
//                            if !pressing {
//                                playSpeedRate = 1
//                                print("not pressing anymore")
//                            }
//                        }
                } else {
                    Color.green
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
            .overlay(alignment: .topLeading) {
                ZStack {
                    ForEach(likedCounter) { like in
                        Icons.heartFill
                            .iconSize(height: 80)
                            .foregroundStyle(Colors.redAccent)
                            .frame(width: 100, height: 100)
                        /// Adding Some Implicit Rotation & Scaling Animation
                            .animation(.smooth, body: { view in
                                view
                                    .scaleEffect(like.isAnimated ? 1 : 1.8)
                                    .rotationEffect(.init(degrees: like.isAnimated ? 0 : .random(in: -30...30)))
                            })
                            .offset(x: like.tappedRect.x - 40, y: like.tappedRect.y - 40)
                        /// Let's Animate
                            .offset(y: like.isAnimated ? -(like.tappedRect.y + 50) : 0)
                    }
                }
            }
        }
        .background(Colors.black)
        .onAppear {
            print("ONAPPEAR")
            if scenePhase == .active && !pausedByUser {
                playPause(offsetKeyValue)
            }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
                case .active:
                    if !pausedByUser {
                        play = true
                    }
                default:
                    play = false
            }
        }
        .onChange(of: time) {
            if let duration = postVM.post.media.first?.duration {
                if !isSeeking {
                    let totalDuration = duration
                    let currentDuration = time
                    let calculatedProgress = currentDuration.seconds / totalDuration

                    progress = calculatedProgress
                    lastDraggedProgress = progress
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let duration = postVM.post.media.first?.duration {
                videoSeekerView(videoDuration: duration)
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
        .onDisappear {
            print("ONDISAPPEAR")
            cleanupPlayer()
        }
    }

    private func cleanupPlayer() {
        print("cleanupPlayer")
        time = .zero
        pausedByUser = false
        play = false
        thumbnailGenerationTask?.cancel()
        thumbnailGenerationTask = nil
    }

    @ViewBuilder
    private var pauseIcon: some View {
        Image(systemName: "play.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 56)
            .foregroundStyle(.white)
            .opacity(0.75)
    }

    @ViewBuilder
    private func reelDetailsView() -> some View {
        HStack(alignment: .bottom, spacing: 5) {
            PostDescriptionComment(postVM: postVM, isInFeed: false)

            PostActionsView(layout: .vertical, postViewModel: postVM)
                .padding(.bottom, -5)
        }
        .padding(.leading, 20)
        .padding(.trailing, 15)
        .padding(.bottom, 20)
        .shadow(color: .black, radius: 40, x: 0, y: 0)
    }

    // MARK: - Play/Pause Logic Based on Offset

    private func playPause(_ rect: CGRect) {
        let visibleHeight = min(rect.height, size.height - rect.minY, rect.maxY)
        let visibilityHeightRatio = visibleHeight / rect.height

        if visibilityHeightRatio > 0.5 {
            if !pausedByUser {
                play = true
            }
        } else {
            play = false

            if visibilityHeightRatio < 0.01 {
                cleanupPlayer()
            }
        }
    }

    private struct ReelLike: Identifiable {
        var id: UUID = .init()
        var tappedRect: CGPoint = .zero
        var isAnimated: Bool = false
    }

    // MARK: - Video Seeker View

    @ViewBuilder
    func videoSeekerView(videoDuration: TimeInterval) -> some View {
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
                            let seekTime = CMTime(seconds: videoDuration * progress, preferredTimescale: 600)
                            time = seekTime

                            isSeeking = false
                        }
                )
                .offset(x: progress * size.width > 15 ? (progress * -15) : 0)
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
        .offset(y: -60)
        .shadow(color: .black, radius: 40, x: 0, y: 0)
//        .frame(width: thumbSize.width, height: thumbSize.height)
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
}
