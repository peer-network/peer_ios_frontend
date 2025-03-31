//
//  KVideoTrimmer.swift
//  PostCreation
//
//  Created by Artem Vasin on 12.03.25.
//

import SwiftUI
import AVKit
import DesignSystem

struct KVideoTrimmer: View {
    var isLong: Bool
    var url: URL
    var minimumDurationInSeconds: CGFloat? = nil
    var maximumDurationInSeconds: CGFloat? = nil
    /// Seeker Customization
    var seekerTint: Color = .gray
    var indicatorTint: Color = .white
    /// Video Properties
    var quality: Quality = .high
    var outputFileType: FileType = .mov
    var onComplete: (URL?, Error?) -> ()
    var onClose: () -> ()
    /// View Properties
    @State private var frameImages: [FrameImage] = []
    @GestureState private var isDragging: Bool = false
    /// Identifies whether the trimmed part is moving
    @GestureState private var isMoving: Bool = false
    @Environment(\.dismiss) private var dismiss
    /// Seeker Properties
    @State private var progress: CGFloat = .zero
    /// Player Properties
    @State private var player: AVPlayer?
    @State private var videoDuration: Double = .zero
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
        ZStack(alignment: .bottom) {
            VideoPreview()

            VStack(spacing: 0) {
                ExportProgressView()

                Spacer()

                FrameBasedVideoTrimmer()

                VideoDurationView()

                NavigationBar()
            }
        }
        .disabled(showExportScreen)
        .opacity(showExportScreen ? 0.7 : 1)
        .task {
            try? await fetchFrames()
            if player == nil {
                player = AVPlayer(url: url)
                let asset = AVAsset(url: url)
                if let videoDuration = try? await asset.load(.duration).seconds {
                    self.videoDuration = videoDuration
                    startTime = CMTime(seconds: 0, preferredTimescale: 60000)
                    endTime = CMTime(seconds: maximumDuration, preferredTimescale: 60000)
                    player?.play()
                }
            }
        }
        .background(.black)
        .environment(\.colorScheme, .dark)
        .toolbar(.hidden, for: .navigationBar)
        .interactiveDismissDisabled()
    }

    /// Navigation Bar
    @ViewBuilder
    private func NavigationBar() -> some View {
        HStack(spacing: 10) {
            changeButton
            nextButton
        }
        .padding(10)
    }

    private var changeButton: some View {
        Button {
            onClose()
        } label: {
            HStack(spacing: 0) {
                Text("Change")
                Spacer()
                Icons.x
                    .iconSize(height: 11)
            }
            .font(.customFont(weight: .bold, style: .footnote))
            .foregroundStyle(Color.white)
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial)
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
            createTrimmedVideoOriginal()
        } label: {
            HStack(spacing: 0) {
                Text("Next")
                Spacer()
                Icons.arrowDownNormal
                    .iconSize(height: 16)
                    .rotationEffect(.degrees(270))
            }
            .font(.customFont(weight: .bold, style: .footnote))
            .foregroundStyle(Color.white)
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

    /// Video Preview
    @ViewBuilder
    private func VideoPreview() -> some View {
        GeometryReader {
            let size = $0.size

            KCustomVideoPlayer(player: player)
                .frame(width: size.width, height: size.height)
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
                .fill(indicatorTint.gradient)
                .frame(width: 5, height: size.height + 7)
                .offset(x: (size.width - 5) * progress)
                .onReceive(Timer.publish(every: 0.1, on: .main, in: .default).autoconnect(), perform: { _ in
                    if !isDragging {
                        if let seconds = player?.currentItem?.currentTime().seconds {
                            let startDuration = (startPosition / width) * videoDuration
                            let trimmedDuration = (trimmedWidth / width) * videoDuration
                            progress = min((seconds - startDuration) / trimmedDuration, 1.0)

                            /// Looping Video
                            if progress == 1 {
                                let time = CMTime(seconds: startDuration, preferredTimescale: 60000)
                                player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
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
                        .fill(indicatorTint)
                        .frame(width: 2, height: 30)
                }
                .frame(maxHeight: .infinity)
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
                .fill(seekerTint.opacity(0.5))
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
                        .stroke(seekerTint, lineWidth: 10)
                        .padding(.horizontal, -5)
                        .padding(.vertical, 1)
                }
                .offset(x: (startPosition - endPosition) / 2)
                .frame(maxWidth: .infinity)
                .zIndex(0)

            Rectangle()
                .fill(seekerTint)
                .frame(width: 10)
                .overlay {
                    Rectangle()
                        .fill(indicatorTint)
                        .frame(width: 2, height: 30)
                }
                .frame(maxHeight: .infinity)
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
                            .fill(seekerTint)
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
        .padding(.vertical, 15)
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
                    .fill(Color.hashtag)
                    .frame(width: width * exportProgres)
            }
        }
        .frame(height: 4)
        .padding(.vertical, 10)
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
            player?.pause()
            /// OPTIONAL: Change this to your preffered URL Directory.
            let outputURL = URL(filePath: NSTemporaryDirectory()).appending(path: "trimmed_video_\(isLong).\(outputFileType.value)")

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
                        onComplete(outputURL, nil)
                    } else {
                        onComplete(nil, session.error)
                    }

                    dismiss()
                }

                showExportScreen = true
            } else {
                onComplete(nil, nil)
            }
        } catch {
            onComplete(nil, error)
            dismiss()
        }
    }

    /// Create Trimmed Video and Compress to Under 80 MB
    private func createTrimmedVideo() {
        do {
            player?.pause()
            /// Output URL for the trimmed video
            let outputURL = URL(filePath: NSTemporaryDirectory()).appending(path: "trimmed_video_\(isLong).\(outputFileType.value)")

            /// Remove existing file if it exists
            if FileManager.default.fileExists(atPath: outputURL.path()) {
                try FileManager.default.removeItem(at: outputURL)
            }

            /// Export Session
            let asset = AVAsset(url: url)
            if let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) {
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
                        compressVideoToTargetSize(outputURL: outputURL, targetSizeMB: 70) { compressedURL, error in
                            if let compressedURL = compressedURL {
                                onComplete(compressedURL, nil)
                            } else {
                                onComplete(nil, error)
                            }
                            dismiss()
                        }
                    } else {
                        onComplete(nil, session.error)
                        dismiss()
                    }
                }

                showExportScreen = true
            } else {
                onComplete(nil, nil)
            }
        } catch {
            onComplete(nil, error)
            dismiss()
        }
    }

    /// Compress Video to Target Size (in MB) with Best Possible Quality
    private func compressVideoToTargetSize(outputURL: URL, targetSizeMB: Double, completion: @escaping (URL?, Error?) -> Void) {
        let asset = AVAsset(url: outputURL)
        let targetSizeBytes = Int64(targetSizeMB * 1024 * 1024) // Convert MB to bytes

        /// Calculate the target bitrate based on the video duration and target size
        let videoDuration = CMTimeGetSeconds(asset.duration)
        let targetBitrate = (targetSizeBytes * 8) / Int64(videoDuration) // Bitrate in bits per second

        /// Output URL for the compressed video
        let compressedURL = URL(filePath: NSTemporaryDirectory()).appending(path: "compressed_video_\(isLong).\(outputFileType.value)")
        if FileManager.default.fileExists(atPath: compressedURL.path()) {
            try? FileManager.default.removeItem(at: compressedURL)
        }

        /// Create AVAssetWriter to write the compressed video
        guard let assetWriter = try? AVAssetWriter(outputURL: compressedURL, fileType: outputFileType.avFileType) else {
            completion(nil, NSError(domain: "VideoCompression", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetWriter"]))
            return
        }

        /// Video Track
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(nil, NSError(domain: "VideoCompression", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video track found"]))
            return
        }

        /// Video Settings
        let videoSize = videoTrack.naturalSize
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: targetBitrate,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]

        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        if assetWriter.canAdd(videoInput) {
            assetWriter.add(videoInput)
        }

        /// Audio Track
        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderBitRateKey: 128000
            ]

            let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            if assetWriter.canAdd(audioInput) {
                assetWriter.add(audioInput)
            }
        }

        /// Start Writing
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: .zero)

        /// Create AVAssetReader to read the video frames
        let assetReader: AVAssetReader
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            completion(nil, error)
            return
        }

        /// Video Output Settings
        let videoOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]

        let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoOutputSettings)
        if assetReader.canAdd(videoOutput) {
            assetReader.add(videoOutput)
        }

        /// Audio Output Settings
        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            let audioOutputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false
            ]

            let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioOutputSettings)
            if assetReader.canAdd(audioOutput) {
                assetReader.add(audioOutput)
            }
        }

        /// Start Reading
        if !assetReader.startReading() {
            completion(nil, assetReader.error)
            return
        }

        /// Process Video Frames
        let videoQueue = DispatchQueue(label: "videoQueue")
        videoInput.requestMediaDataWhenReady(on: videoQueue) {
            while videoInput.isReadyForMoreMediaData {
                if let sampleBuffer = videoOutput.copyNextSampleBuffer() {
                    videoInput.append(sampleBuffer)
                } else {
                    videoInput.markAsFinished()
                    break
                }
            }
        }

        /// Process Audio Frames
        if let audioInput = assetWriter.inputs.first(where: { $0.mediaType == .audio }) {
            let audioQueue = DispatchQueue(label: "audioQueue")
            audioInput.requestMediaDataWhenReady(on: audioQueue) {
                while audioInput.isReadyForMoreMediaData {
                    if let sampleBuffer = assetReader.outputs.first(where: { $0.mediaType == .audio })?.copyNextSampleBuffer() {
                        audioInput.append(sampleBuffer)
                    } else {
                        audioInput.markAsFinished()
                        break
                    }
                }
            }
        }

        /// Finish Writing
        assetWriter.finishWriting {
            switch assetWriter.status {
            case .completed:
                let compressedFileSizeMB = self.getFileSizeMB(of: compressedURL)
                print("📁 Compressed File Size: \(String(format: "%.2f", compressedFileSizeMB)) MB")
                completion(compressedURL, nil)
            case .failed:
                completion(nil, assetWriter.error)
            default:
                break
            }
        }
    }

    /// Helper: Get the next sample buffer for a track
    private func nextSampleBuffer(for track: AVAssetTrack, at time: CMTime) -> CMSampleBuffer? {
        let assetReader: AVAssetReader
        do {
            assetReader = try AVAssetReader(asset: AVAsset(url: url))
        } catch {
            return nil
        }

        let outputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]

        let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        if assetReader.canAdd(trackOutput) {
            assetReader.add(trackOutput)
        }

        assetReader.startReading()
        return trackOutput.copyNextSampleBuffer()
    }

    /// Helper: Get File Size in MB
    private func getFileSizeMB(of url: URL) -> Double {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[.size] as? Int64 {
                return Double(fileSize) / (1024 * 1024)  // Convert bytes to MB
            }
        } catch {
            print("❌ Failed to get file size: \(error.localizedDescription)")
        }
        return 0.0
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

fileprivate struct KCustomVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer?
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
