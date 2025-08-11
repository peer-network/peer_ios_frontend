//
//  AudioCoverPicker.swift
//  PostCreation
//
//  Created by Artem Vasin on 05.06.25.
//

import SwiftUI
import PhotosUI

struct AudioCoverPicker<Content: View>: View {
    @Binding var imageState: ImageState?
    @State private var selectedItem: PhotosPickerItem?

    @ViewBuilder let content: () -> Content

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()) {
                content()
            }
            .photosPickerStyle(.presentation)
            .onChange(of: selectedItem) {
                guard let selectedItem else { return }

                Task {
                    try? await Task.sleep(for: .seconds(0.5))
                    await processSelectedItem(selectedItem)
                }
            }
    }

    private func processSelectedItem(_ item: PhotosPickerItem) async {
        let id = "\(item.itemIdentifier ?? "unknown")"

        await MainActor.run {
            imageState = ImageState(id: id, state: .loading, pickerItem: item)
        }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    imageState = ImageState(id: id, state: .loaded(uiImage), pickerItem: item)
                }
            } else {
                throw ImageLoadingError.failedToLoadImage
            }
        } catch {
            await MainActor.run {
                imageState = ImageState(id: id, state: .failed(error))
                showPopup(text: error.localizedDescription)
            }
        }
    }
}
