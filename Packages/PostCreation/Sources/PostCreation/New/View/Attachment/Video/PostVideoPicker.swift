//
//  PostVideoPicker.swift
//  PostCreation
//
//  Created by Artem Vasin on 28.05.25.
//

import SwiftUI
@preconcurrency import PhotosUI

enum VideoLoadingError: Error, LocalizedError {
    case failedToLoadVideo
    case failedToGenerateThumbnail
    case videoTooShort

    var errorDescription: String? {
        switch self {
            case .failedToLoadVideo:
                return "Failed to load the selected video"
            case .failedToGenerateThumbnail:
                return "Couldn't generate preview for the video"
            case .videoTooShort:
                return "Video length must be at least 5 seconds"
        }
    }
}

struct VideoState {
    enum LoadingState {
        case loading
        case loaded(thumbnail: Image, videoURL: URL, duration: Double?)
    }

    let id: String
    var state: LoadingState
}

struct PostVideoPicker<Content: View>: View {
    @Binding var videoState: VideoState?
    @ViewBuilder let content: () -> Content

    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .videos,
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()) {
                content()
            }
            .photosPickerStyle(.presentation)
            .onChange(of: selectedItem) {
                guard let selectedItem else { return }

                Task {
                    try? await Task.sleep(for: .seconds(0.5))
                    videoState = VideoState(id: selectedItem.itemIdentifier ?? UUID().uuidString, state: .loading)
                    await processSelectedItem(selectedItem)
                }
            }
    }

    private func processSelectedItem(_ item: PhotosPickerItem) async {
        do {
            // Load video file
            guard let videoFile = try await item.loadTransferable(type: VideoFileTransferable.self) else {
                throw VideoLoadingError.failedToLoadVideo
            }

            let asset = AVAsset(url: videoFile.url)

            // Get duration
            let duration = try? await asset.load(.duration)

            if duration?.seconds ?? 0 < 5 {
                throw VideoLoadingError.videoTooShort
            }

            // Generate thumbnail
            guard let thumbnailImage = await generateThumbnail(from: asset) else {
                throw VideoLoadingError.failedToGenerateThumbnail
            }

            if videoState?.id == item.itemIdentifier {
                // Update with loaded state
                await MainActor.run {
                    videoState = VideoState(
                        id: item.itemIdentifier ?? UUID().uuidString,
                        state: .loaded(thumbnail: Image(uiImage: thumbnailImage), videoURL: videoFile.url, duration: duration?.seconds))
                }
            }
        } catch {
            if videoState?.id == item.itemIdentifier {
                await MainActor.run {
                    videoState = nil
                    showPopup(text: error.userFriendlyDescription)
                }
            }
        }
    }

    private func generateThumbnail(from asset: AVAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero

            let time = CMTime(seconds: 0, preferredTimescale: 600)

            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, _, error in
                if let image = image {
                    continuation.resume(returning: UIImage(cgImage: image))
                } else {
                    // Fallback to alternative method if first frame fails
                    self.generateFirstFrameFallback(asset: asset, continuation: continuation)
                }
            }
        }
    }

    private func generateFirstFrameFallback(asset: AVAsset,
                                            continuation: CheckedContinuation<UIImage?, Never>) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            continuation.resume(returning: UIImage(cgImage: cgImage))
        } catch {
            continuation.resume(returning: nil)
        }
    }
}
