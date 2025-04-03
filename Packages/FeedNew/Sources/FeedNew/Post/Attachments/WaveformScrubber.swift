//
//  WaveformScrubber.swift
//  FeedNew
//
//  Created by Artem Vasin on 27.03.25.
//

import SwiftUI
import AVKit

struct WaveformScrubber: View {
    var config: Config = .init()
    var url: URL

    /// Scrubber Progress
    @Binding var progress: CGFloat
    @Binding var playClicked: Bool
    var info: (AudioInfo) -> () = { _ in }
    var onGestureActive: (Bool) -> () = { _ in }
    var onGestureEnded: () -> Void = {  }

    /// View Properties
    @State private var samples: [Float] = []
    @State private var dowsizedSamples: [Float] = []
    @State private var viewSize: CGSize = .zero

    @State private var audioFileURL: URL?
    @State private var isLoading: Bool = false
    @State private var error: Error?

    /// Gesture Properties
    @State private var lastProgress: CGFloat = 0
    @GestureState private var isActive: Bool = false

    // Calculate number of bars needed based on view width
    private var barCount: Int {
        guard viewSize.width > 0 else { return 50 } // Default count
        return Int(viewSize.width / CGFloat(config.spacing + config.shapeWidth))
    }

    // Generate placeholder samples (all minimal height)
    private var placeholderSamples: [Float] {
        Array(repeating: 0.1, count: barCount)
    }

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                WaveformShape(samples: audioFileURL == nil || isLoading || error != nil ? placeholderSamples : dowsizedSamples)
                    .fill(config.inActiveTint)
                    .opacity(isLoading || error != nil ? 0.5 : 1)

                WaveformShape(samples: audioFileURL == nil || isLoading || error != nil ? placeholderSamples : dowsizedSamples)
                    .fill(config.activeTint)
                    .mask {
                        Rectangle()
                            .scale(x: progress, anchor: .leading)
                    }
                    .opacity(isLoading || error != nil ? 0.5 : 1)

                if isLoading || error != nil {
                    ProgressView()
                        .controlSize(.large)
                        .scaleEffect(y: 1.3, anchor: .center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .gesture(
            DragGesture()
                .updating($isActive, body: { _, out, _ in
                    out = true
                })
                .onChanged { value in
                    let progress = max(min((value.translation.width / viewSize.width) + lastProgress, 1), 0)
                    self.progress = progress
                }
                .onEnded { _ in
                    lastProgress = progress
                    onGestureEnded()
                }
        )
        .onChange(of: progress) {
            guard !isActive else { return }
            lastProgress = progress
        }
        .onChange(of: isActive) {
            onGestureActive(isActive)
        }
        .onChange(of: playClicked) {
            if playClicked == true, audioFileURL == nil {
                downloadAudioFile()
            }
        }
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: { newValue in
            /// Storing Initial Progress
            if viewSize == .zero {
                lastProgress = progress
            }

            viewSize = newValue
        }
    }

    struct Config {
        var spacing: Float = 3
        var shapeWidth: Float = 3.5
        var activeTint: Color = .blue
        var inActiveTint: Color = .white
    }

    struct AudioInfo {
        var duration: TimeInterval = 0
    }
}

/// Custom WaveFrom Shape
fileprivate struct WaveformShape: Shape {
    var samples: [Float]
    var spacing: Float = 3
    var width: Float = 3.5
    var minHeight: CGFloat = 7
    var cornerRadius: CGFloat = 53

    nonisolated func path(in rect: CGRect) -> Path {
        Path { path in
            var x: CGFloat = 0

            for sample in samples {
                let height = max(CGFloat(sample) * rect.height, minHeight)

                let barRect = CGRect(
                    origin: .init(x: x + CGFloat(width), y: -height / 2),
                    size: .init(width: CGFloat(width), height: height)
                )

                path.addRoundedRect(in: barRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

                x += CGFloat(spacing + width)
            }
        }
        .offsetBy(dx: 0, dy: rect.height / 2)
    }
}

/// Audio Helpers
extension WaveformScrubber {
    private func downloadAudioFile() {
        guard url.isFileURL == false else {
            audioFileURL = url
            initializeAudioFile(viewSize)
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                let (tempURL, _) = try await URLSession.shared.download(from: url)

                // Move to a permanent location in temp directory
                let destinationURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(url.pathExtension)

                try? FileManager.default.removeItem(at: destinationURL)
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)

                await MainActor.run {
                    audioFileURL = destinationURL
                    isLoading = false
                    initializeAudioFile(viewSize)
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }

    private func initializeAudioFile(_ size: CGSize) {
        guard let audioFileURL = audioFileURL, samples.isEmpty else { return }

        Task.detached(priority: .high) {
            do {
                let audioFile = try AVAudioFile(forReading: audioFileURL)
                let audioInfo = extractAudioInfo(audioFile)
                let samples = try extractAudioSamples(audioFile)

                let downSampleCount = Int(Float(size.width) / (config.spacing + config.shapeWidth))
                let downSamples = downSampleAudioSamples(samples, downSampleCount)

                await MainActor.run {
                    self.samples = samples
                    self.dowsizedSamples = downSamples
                    self.info(audioInfo)
                }
            } catch {
                print(error.localizedDescription)
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    nonisolated private func extractAudioSamples(_ file: AVAudioFile) throws -> [Float] {
        let format = file.processingFormat
        let frameCount = UInt32(file.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return []
        }

        try file.read(into: buffer)

        if let channel = buffer.floatChannelData {
            let samples = Array(UnsafeBufferPointer(start: channel[0], count: Int(buffer.frameLength)))
            return samples
        }

        return []
    }

    nonisolated private func downSampleAudioSamples(_ samples: [Float], _ count: Int) -> [Float] {
        let chunk = samples.count / count
        var downSamples: [Float] = []

        for index in 0..<count {
            let start = index * chunk
            let end = min((index + 1) * chunk, samples.count)
            let chunkSamples = samples[start..<end]

            let maxValue = chunkSamples.max() ?? 0
            downSamples.append(maxValue)
        }

        return downSamples
    }

    nonisolated private func extractAudioInfo(_ file: AVAudioFile) -> AudioInfo {
        let format = file.processingFormat
        let sampleRate = format.sampleRate

        let duration = file.length / Int64(sampleRate)

        return .init(duration: TimeInterval(duration))
    }
}
