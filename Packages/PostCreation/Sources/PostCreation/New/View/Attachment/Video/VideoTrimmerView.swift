//
//  VideoTrimmerView.swift
//  PostCreation
//
//  Created by Artem Vasin on 30.05.25.
//

import SwiftUI
import AVKit
import DesignSystem

struct VideoTrimmerView: View {
    @Binding var player: AVPlayer?
    @Binding var isPlaying: Bool
    var videoDuration: Double
    var url: URL
    var minimumDurationInSeconds: CGFloat? = nil
    var maximumDurationInSeconds: CGFloat? = nil
    /// Seeker Customization
    var seekerTint: Color = .gray
    var indicatorTint: Color = .white
    /// Video Properties
    var quality: Quality = .high
    var outputFileType: FileType = .mov
    var onComplete: (URL?, Double?, Error?) -> ()
    var onClose: () -> ()
    /// View Properties
    @State private var frameImages: [FrameImage] = []
    @GestureState private var isDragging: Bool = false
    /// Identifies whether the trimmed part is moving
    @GestureState private var isMoving: Bool = false
    /// Seeker Properties
    @State private var progress: CGFloat = .zero
    /// Trimmer Properties
    @State private var startPosition: CGFloat = .zero
    @State private var lastStartPosition: CGFloat = .zero
    @State private var endPosition: CGFloat = .zero
    @State private var lastEndPosition: CGFloat = .zero
    @State private var dragPosition: CGFloat = .zero
    @State private var excessDragPosition: CGFloat = .zero
    @State private var trimmedWidth: CGFloat = .zero
    @State private var startTime: CMTime = .zero
    @State private var endTime: CMTime = .zero
    /// Exporting Properties
    @State private var showExportScreen: Bool = false
    @State private var exportProgres: CGFloat = .zero
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            FrameBasedVideoTrimmer()
                .padding(.vertical, 15)

            VideoDurationView()

            ExportProgressView()
                .padding(.vertical, 10)

            NavigationBar()
                .padding(.top, 10)
        }
        .disabled(showExportScreen)
        .opacity(showExportScreen ? 0.7 : 1)
        .onAppear {
            startTime = CMTime(seconds: 0, preferredTimescale: 60000)
            endTime = CMTime(seconds: maximumDuration, preferredTimescale: 60000)
            isPlaying = true
            player?.play()
        }
        .task {
            try? await fetchFrames()
        }
        .onDisappear(perform: {
            reset()
        })
        .environment(\.colorScheme, .dark)
        .interactiveDismissDisabled()
    }

    private func reset() {
        progress = .zero

        startPosition = .zero
        lastStartPosition = .zero
        endPosition = .zero
        lastEndPosition = .zero
        dragPosition = .zero
        excessDragPosition = .zero
        trimmedWidth = .zero
        startTime = .zero
        endTime = .zero

        showExportScreen = false
        exportProgres = .zero

        frameImages.removeAll()
    }

    /// Navigation Bar
    @ViewBuilder
    private func NavigationBar() -> some View {
        HStack(spacing: 10) {
            changeButton
            nextButton
        }
    }

    private var changeButton: some View {
        Button {
            onClose()
        } label: {
            Text("Cancel")
                .font(.customFont(weight: .bold, style: .footnote))
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                }
        }
    }

    private var nextButton: some View {
        Button {
            createTrimmedVideoOriginal()
        } label: {
            Text("Save")
                .font(.customFont(weight: .bold, style: .footnote))
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background(Gradients.activeButtonBlue)
                .cornerRadius(24)
        }
    }
    
    /// Frame Video Resizer & Slider
    @ViewBuilder
    private func FrameBasedVideoTrimmer() -> some View {
        GeometryReader {
            let size = $0.size

            HStack(spacing: 0) {
                ForEach(frameImages) { frame in
                    GeometryReader {
                        let size = $0.size

                        if let image = frame.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipped()
                        }
                    }
                }
            }
            .onAppear {
                if trimmedWidth == .zero {  trimmedWidth = size.width - 20 }
            }
            .padding(.horizontal, 10)
            /// Seeker & Resizer
            .overlay(alignment: .leading) {
                if size != .zero && videoDuration != .zero {
                    VideoTrimmerView(size: size)
                }
            }
        }
        .frame(height: 50)
        .padding([.horizontal, .top], 15)
    }

    /// Current Duration Indicator
    @ViewBuilder
    private func VideoDurationIndicator(width: CGFloat) -> some View {
        GeometryReader {
            let size = $0.size

            Capsule()
                .fill(Colors.hashtag)
                .frame(width: 5, height: size.height)
                .offset(x: (size.width - 5) * progress)
                .onReceive(Timer.publish(every: 0.01, on: .main, in: .default).autoconnect(), perform: { _ in
                    if !isDragging {
                        if let seconds = player?.currentItem?.currentTime().seconds {
                            let startDuration = (startPosition / width) * videoDuration
                            let trimmedDuration = (trimmedWidth / width) * videoDuration
                            progress = min((seconds - startDuration) / trimmedDuration, 1.0)

                            /// Looping Video
                            if progress == 1 {
                                let time = CMTime(seconds: startDuration, preferredTimescale: 60000)
                                player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
                                isPlaying = true
                                player?.play()
                            }
                        }
                    }
                })
        }
    }

    /// Custom Video Trimmer Composed With Video Frame Images
    @ViewBuilder
    private func VideoTrimmerView(size: CGSize) -> some View {
        let clippedWidth = size.width - 20
        let oneSecEquivalentWidth = clippedWidth / videoDuration
        let minimumClippedWidth = clippedWidth - (oneSecEquivalentWidth * minimumDuration)
        let maximumClippedWidth = clippedWidth - (oneSecEquivalentWidth * maximumDuration)

        HStack(spacing: 0) {
            Rectangle()
                .fill(seekerTint)
                .frame(width: 10)
                .overlay {
                    Rectangle()
                        .fill(Colors.inactiveDark)
                        .frame(width: 2, height: 30)
                }
                .frame(maxHeight: .infinity)
                .roundedCorner(24, corners: [.topLeft, .bottomLeft])
                .contentShape(.rect)
                .offset(x: startPosition)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($isDragging, body: { _, out, _ in
                            out = true
                        })
                        .onChanged { value in
                            progress = .zero
                            let translation = value.translation.width + lastStartPosition
                            let minValue = minimumClippedWidth - endPosition
                            let maxValue = maximumClippedWidth - endPosition

                            startPosition = max(max(min(translation, minValue), 0), maxValue)
                            updateStartTime(clippedWidth)
                        }.onEnded { _ in
                            lastStartPosition = startPosition
                        }
                )
                .zIndex(1)

            Rectangle()
                .fill(seekerTint.opacity(0.01))
                .frame(width: trimmedWidth)
                .overlay(alignment: .leading) {
                    VideoDurationIndicator(width: clippedWidth)
                        .overlay(alignment: .top) {
                            TrimmedDurationPopup(width: clippedWidth)
                                .padding(.horizontal, 5)
                        }
                }
                .background {
                    Rectangle()
                        .strokeBorder(seekerTint, lineWidth: 5)
                        .padding(.horizontal, -5)
                }
                .offset(x: (startPosition - endPosition) / 2)
                .frame(maxWidth: .infinity)
                .zIndex(0)

            Rectangle()
                .fill(seekerTint)
                .frame(width: 10)
                .overlay {
                    Rectangle()
                        .fill(Colors.inactiveDark)
                        .frame(width: 2, height: 30)
                }
                .frame(maxHeight: .infinity)
                .roundedCorner(24, corners: [.topRight, .bottomRight])
                .contentShape(.rect)
                .offset(x: -endPosition)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($isDragging, body: { _, out, _ in
                            out = true
                        })
                        .onChanged { value in
                            progress = 1.0
                            let translation = (value.translation.width + lastEndPosition)
                            let minValue = minimumClippedWidth - startPosition
                            let maxValue = maximumClippedWidth - startPosition

                            endPosition = max(max(min(-translation, minValue), 0), maxValue)
                            updateEndTime(clippedWidth)
                        }.onEnded { _ in
                            lastEndPosition = -endPosition
                        }
                )
        }
        /// Moving Trimmed Area
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isMoving) { _, out, _ in
                    out = true
                }.updating($isDragging) { _, out, _ in
                    out = true
                }.onChanged { value in
                    progress = .zero

                    let xValue = value.translation.width
                    let velocity = value.velocity.width / 10
                    let translation = startPosition == 0 && velocity < 0 ? dragPosition : endPosition == 0 && velocity > 0 ? dragPosition : (xValue - excessDragPosition)

                    /// Updating Start Position
                    let minStartValue = clippedWidth - trimmedWidth
                    startPosition = max(min(translation + lastStartPosition, minStartValue), 0)

                    /// Updating End Position
                    let minEndValue = clippedWidth - trimmedWidth
                    endPosition = max(min(-(translation + lastEndPosition), minEndValue), 0)

                    updateStartTime(clippedWidth)
                    updateEndTime(clippedWidth, updatePlayer: false)

                    dragPosition = translation
                    excessDragPosition = xValue - dragPosition
                }.onEnded { value in
                    dragPosition = .zero
                    excessDragPosition = .zero
                    lastStartPosition = startPosition
                    lastEndPosition = -endPosition
                }
        )
        .task {
            endPosition = maximumClippedWidth
            lastEndPosition = -maximumClippedWidth
        }
        .onChange(of: startPosition) {
            if !isMoving {
                trimmedWidth = clippedWidth - (startPosition + endPosition)
            }
        }
        .onChange(of: endPosition) {
            if !isMoving {
                trimmedWidth = clippedWidth - (startPosition + endPosition)
            }
        }
        .onChange(of: isDragging) {
            if isDragging {
                player?.pause()
            } else {
                progress = .zero
                player?.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero)
                isPlaying = true
                player?.play()
            }
        }
    }

    /// Updates Trimming Start With Video Preview
    private func updateStartTime(_ width: CGFloat) {
        let trimmedProgress = startPosition / width
        let time = CMTime(seconds: trimmedProgress * videoDuration, preferredTimescale: 60000)
        startTime = time
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    /// Updates Trimming End With Video Preview
    private func updateEndTime(_ width: CGFloat, updatePlayer: Bool = true) {
        let trimmedProgress = (width - endPosition) / width
        let time = CMTime(seconds: trimmedProgress * videoDuration, preferredTimescale: 60000)
        endTime = time
        if updatePlayer { player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) }
    }

    /// Trimmed Duration Popup
    @ViewBuilder
    func TrimmedDurationPopup(width: CGFloat) -> some View {
        GeometryReader {
            let minX = $0.frame(in: .global).minX
            let trailingCondition = width - 60

            if isDragging || isMoving {
                Text(trimmedDuration)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(indicatorTint)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Colors.hashtag)
                    }
                    .fixedSize()
                    .frame(maxWidth: .infinity)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                    .offset(x: minX < 0 ? -minX : (minX > trailingCondition ? -(minX - trailingCondition) : 0))
            }
        }
        .offset(y: -40)
        .animation(.snappy, value: isDragging || isMoving)
    }

    private var trimmedDuration: String {
        let range = CMTimeRange(start: startTime, end: endTime)
        return range.duration.seconds.format(style: .short)
    }

    /// Video Duration View
    @ViewBuilder
    private func VideoDurationView() -> some View {
        HStack(spacing: 10) {
            ForEach(0..<10, id: \.self) { index in
                VStack(spacing: 4) {
                    Circle()
                        .fill(.gray)
                        .frame(width: 5, height: 5)

                    if index == 0 {
                        Text(0.0.format(style: .positional))
                            .font(.caption2)
                            .foregroundStyle(.gray)
                            .fixedSize()
                    }

                    if index == 9 {
                        Text(videoDuration.format(style: .positional))
                            .font(.caption2)
                            .foregroundStyle(.gray)
                            .fixedSize()
                    }

                    Spacer(minLength: 0)
                }
                .lineLimit(1)
                .frame(height: 20)
                .frame(maxWidth: .infinity)
            }
        }
    }

    /// Export Progress Screen
    @ViewBuilder
    private func ExportProgressView() -> some View {
        GeometryReader {
            let width = $0.size.width

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray)

                Rectangle()
                    .fill(Gradients.activeButtonBlue)
                    .frame(width: width * exportProgres)
            }
        }
        .frame(height: 5)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .opacity(showExportScreen ? 1 : 0)
    }

    /// Fetching Frames For Slider
    private func fetchFrames(_ seekerFrameCount: Int = 10) async throws {
        guard frameImages.isEmpty else { return }

        Task.detached {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let totalDuration = try await asset.load(.duration).seconds

            let splits = Int(totalDuration) / seekerFrameCount
            let time = (0..<seekerFrameCount).compactMap({
                let seconds = $0 * splits
                return CMTime(value: CMTimeValue(seconds), timescale: 1)
            })

            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.maximumSize = .init(width: 100, height: 100)

            guard let images = try await imageGenerator.images(for: time).reduce([], { partialResult, element in
                let cgImage = try element.image
                let image = FrameImage(image: UIImage(cgImage: cgImage))
                let newArray = partialResult + [image]

                return newArray
            }) as? [FrameImage] else { return }

            await MainActor.run {
                self.frameImages = images
            }
        }
    }

    /// Creating Trimmed Video
    private func createTrimmedVideoOriginal() {
        do {
            isPlaying = false
            player?.pause()
            player = nil

            let outputURL = URL(filePath: NSTemporaryDirectory()).appending(path: "trimmed_video_\(UUID().uuidString).\(outputFileType.value)")

            /// Removing Existing Item
            if FileManager.default.fileExists(atPath: outputURL.path()) {
                try FileManager.default.removeItem(at: outputURL)
            }

            /// Export Session
            let asset = AVAsset(url: url)
            if let session = AVAssetExportSession(asset: asset, presetName: quality.value) {
                session.outputURL = outputURL
                session.outputFileType = outputFileType.avFileType
                let trimRange = CMTimeRange(start: startTime, end: endTime)
                session.timeRange = trimRange

                let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    exportProgres = CGFloat(session.progress)
                }

                timer.fire()

                session.exportAsynchronously {
                    timer.invalidate()

                    if session.status == .completed {
                        let asset = AVAsset(url: outputURL)
                        let duration = asset.duration.seconds
                        onComplete(outputURL, duration, nil)
                    } else {
                        onComplete(nil, nil, session.error)
                    }
                }

                showExportScreen = true
            } else {
                onComplete(nil, nil, nil)
            }
        } catch {
            onComplete(nil, nil, error)
        }
    }

    /// Time Range Duration's
    private var minimumDuration: CGFloat {
        if let minimumDurationInSeconds {
            return minimumDurationInSeconds > 0 ? minimumDurationInSeconds : 1
        }

        return 1
    }

    private var maximumDuration: CGFloat {
        if let maximumDurationInSeconds {
            return maximumDurationInSeconds > videoDuration ? videoDuration : maximumDurationInSeconds
        }

        return videoDuration
    }

    /// Video Quality
    enum Quality {
        case high
        case medium
        case low
        case custom

        var value: String {
            switch self {
            case .high: return AVAssetExportPresetHighestQuality
            case .medium: return AVAssetExportPresetMediumQuality
            case .low: return AVAssetExportPresetLowQuality
            case .custom: return AVAssetExportPresetPassthrough
            }
        }
    }

    /// Output File Format
    enum FileType {
        case mov
        case mp4

        var value: String {
            switch self {
            case .mov:
                return "mov"
            case .mp4:
                return "mp4"
            }
        }

        var avFileType: AVFileType {
            switch self {
            case .mov:
                return .mov
            case .mp4:
                return .mp4
            }
        }
    }

    /// Frame Image Model
    private struct FrameImage: Identifiable {
        let id: UUID = .init()
        var image: UIImage?
    }
}

fileprivate extension Double {
    func format(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = style
        return formatter.string(from: self) ?? ""
    }
}
