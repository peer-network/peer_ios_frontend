//
//  PostPhotoPicker.swift
//  PostCreation
//
//  Created by Artem Vasin on 28.05.25.
//

import SwiftUI
import PhotosUI

enum ImageLoadingError: Error, LocalizedError {
    case failedToLoadImage

    var errorDescription: String? {
        switch self {
            case .failedToLoadImage:
                return "Failed to load the selected image."
        }
    }
}

struct PostPhotoPicker<Content: View>: View {
    @Binding var imageStates: [ImageState]?
    @Binding var selectedItems: [PhotosPickerItem]

    @ViewBuilder let content: () -> Content

    @State private var newSelectedItems: [PhotosPickerItem] = []

    var body: some View {
        PhotosPicker(
            selection: $newSelectedItems,
            maxSelectionCount: Constants.imageAmountLimit,
            selectionBehavior: .ordered,
            matching: .images,
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()) {
                content()
            }
            .photosPickerStyle(.presentation)
            .onChange(of: newSelectedItems) { oldItems, newItems in
                guard newItems != oldItems else { return }

                guard newItems != selectedItems else { return }

                selectedItems = newItems

                Task {
                    try? await Task.sleep(for: .seconds(0.5))
                    await processSelectedItems(newItems)
                }
            }
            .onAppear {
                newSelectedItems = selectedItems
            }
            .onChange(of: selectedItems) {
                guard newSelectedItems != selectedItems else { return }
                newSelectedItems = selectedItems
            }
    }

    private func processSelectedItems(_ items: [PhotosPickerItem]) async {
        var newImageStates: [ImageState] = []

        await MainActor.run {
            imageStates?.removeAll()
        }

        // Create loading states for all new items
        for (index, item) in items.enumerated() {
            let id = "\(item.itemIdentifier ?? "unknown")-\(index)"
            let loadingState = ImageState(id: id, state: .loading, pickerItem: item)
            newImageStates.append(loadingState)
        }

        // Update UI with loading states
        await MainActor.run {
            imageStates = newImageStates
        }

        // Process each item sequentially to maintain order
        for (index, item) in items.enumerated() {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    updateImageState(at: index, with: .loaded(uiImage))
                } else {
                    throw ImageLoadingError.failedToLoadImage
                }
            } catch {
                updateImageState(at: index, with: .failed(error))
                await MainActor.run {
                    showPopup(text: error.localizedDescription)
                }
            }
        }
    }

    @MainActor
    private func updateImageState(at index: Int, with state: ImageState.LoadingState) {
        guard imageStates != nil, index < imageStates!.count else { return }
        imageStates![index].state = state
    }
}
