//
//  SelectedImagesView.swift
//  PostCreation
//
//  Created by Artem Vasin on 01.06.25.
//

import SwiftUI
import DesignSystem
import PhotosUI

struct SelectedImagesView: View {
    @Binding var imageStates: [ImageState]?
    @Binding var pickerItems: [PhotosPickerItem]
    @Binding var showCroppingView: Bool
    @Binding var imagesAspectRatio: PostImagesAspectRatio

    @State private var editingImageIndex: Int? = nil
    @State private var currentPageID: String? = nil

    private var screenWidth: CGFloat {
        getRect().width
    }

    var body: some View {
        VStack(spacing: 20) {
            if !showCroppingView {
                pageContentView(states: imageStates ?? [])
                    .frame(maxWidth: .infinity)

                aspectRatioButtons()
            } else {
                if case .loaded(let image) = imageStates?[editingImageIndex ?? 0].state {
                    InlineCropView(
                        image: image,
                        aspectRatio: imagesAspectRatio,
                        onCrop: { croppedImage in
                            if let i = editingImageIndex, let id = imageStates?[i].id {
                                currentPageID = id
                                imageStates?[i].state = .loaded(croppedImage)
                            }
                            editingImageIndex = nil
                            showCroppingView = false
                        },
                        onCancel: {
                            if let i = editingImageIndex, let id = imageStates?[i].id {
                                currentPageID = id
                            }
                            editingImageIndex = nil
                            showCroppingView = false
                        }
                    )
                }
            }
        }
        .padding(.top, 7)
    }

    @ViewBuilder
    private func pageContentView(states: [ImageState]) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(states.enumerated()), id: \.element.id) { (index, imageState) in
                        Group {
                            switch imageState.state {
                                case .loading:
                                    loadingPlaceholder
                                case .loaded(let image):
                                    imageView(image)
                                case .failed(let error):
                                    imageErrorView(error)
                            }
                        }
                        .id(imageState.id)
                        .overlay(alignment: .top) {
                            if editingImageIndex != index {
                                HStack {
                                    // Edit button
                                    if case .loaded(_) = imageState.state {
                                        Button {
                                            editImage(at: index)
                                        } label: {
                                            Image(systemName: "crop")
                                                .font(.footnote)
                                                .foregroundStyle(Colors.whitePrimary)
                                                .padding(8)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                    }

                                    Spacer()

                                    // Remove button
                                    Button {
                                        withAnimation {
                                            pickerItems.removeAll(where: { $0.itemIdentifier == imageState.pickerItem?.itemIdentifier })
                                            imageStates?.removeAll(where: { $0.id == imageState.id })
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.footnote)
                                            .foregroundStyle(Colors.whitePrimary)
                                            .padding(8)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(8)
                                .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 4)
                            }
                        }
                        .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 4)
                        .padding(.horizontal, 10)
                        .containerRelativeFrame(.horizontal)
                    }

                    if states.count < 20 {
                        PostPhotoPicker(imageStates: $imageStates, selectedItems: $pickerItems) {
                            addPhotoButton
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 4)
                        .padding(.horizontal, 10)
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
                .overlay(alignment: .bottom) {
                    PagingIndicator(
                        activeTint: Colors.whitePrimary,
                        inActiveTint: Colors.whiteSecondary,
                        opacityEffect: true,
                        clipEdges: true
                    )
                }
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
//            .scrollPosition(id: $currentPageID)
            .safeAreaPadding(.horizontal, 20)
            .onAppear {
                guard !showCroppingView, let id = currentPageID else { return }
                proxy.scrollTo(id, anchor: .center)
            }
        }
    }

    @ViewBuilder
    private func aspectRatioButtons() -> some View {
        HStack(spacing: 10) {
            let configSquareButton = StateButtonConfig(buttonSize: .small, buttonType: imagesAspectRatio == .square ? .secondary : .teritary, title: "1:1 Square")
            StateButton(config: configSquareButton) {
                withAnimation {
                    imagesAspectRatio = .square
                }
            }
            .frame(width: screenWidth / 3)

            let configVerticalButton = StateButtonConfig(buttonSize: .small, buttonType: imagesAspectRatio == .vertical ? .secondary : .teritary, title: "4:5 Vertical")
            StateButton(config: configVerticalButton) {
                withAnimation {
                    imagesAspectRatio = .vertical
                }
            }
            .frame(width: screenWidth / 3)
        }
        .geometryGroup()
    }

    private var loadingPlaceholder: some View {
        ProgressView()
            .controlSize(.large)
            .frame(width: imagesAspectRatio.imageFrameWidth(for: screenWidth), height: imagesAspectRatio.imageFrameHeight(for: screenWidth))
            .background(Colors.inactiveDark)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: imagesAspectRatio.imageFrameWidth(for: screenWidth), height: imagesAspectRatio.imageFrameHeight(for: screenWidth))
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func imageErrorView(_ error: Error) -> some View {
        Text("Error: \(error.localizedDescription)")
            .frame(width: imagesAspectRatio.imageFrameWidth(for: screenWidth), height: imagesAspectRatio.imageFrameHeight(for: screenWidth))
            .background(Colors.inactiveDark)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var addPhotoButton: some View {
        Text("Choose photo")
            .font(.customFont(style: .callout))
            .foregroundStyle(Colors.whiteSecondary)
            .frame(width: imagesAspectRatio.imageFrameWidth(for: screenWidth), height: imagesAspectRatio.imageFrameHeight(for: screenWidth))
            .background(Colors.inactiveDark)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func editImage(at index: Int) {
        currentPageID = imageStates?[index].id
        editingImageIndex = index
        showCroppingView = true
    }
}

private struct PagingIndicator: View {
    /// Customization Properties
    var activeTint: Color = Colors.whitePrimary
    var inActiveTint: Color = Colors.whiteSecondary
    var opacityEffect: Bool = false
    var clipEdges: Bool = false
    var body: some View {
        GeometryReader {
            /// Entire View Size for Calculating Pages
            let width = $0.size.width
            /// ScrollView Bounds
            if let scrollViewWidth = $0.bounds(of: .scrollView(axis: .horizontal))?.width, scrollViewWidth > 0 {
                let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
                let totalPages = Int(width / scrollViewWidth)
                /// Progress
                let freeProgress = -minX / scrollViewWidth
                let clippedProgress = min(max(freeProgress, 0.0), CGFloat(totalPages - 1))
                let progress = clipEdges ? clippedProgress : freeProgress
                /// Indexes
                let activeIndex = Int(progress)
                let nextIndex = Int(progress.rounded(.awayFromZero))
                let indicatorProgress = progress - CGFloat(activeIndex)
                /// Indicator Width's (Current & Upcoming)
                let currentPageWidth = 18 - (indicatorProgress * 18)
                let nextPageWidth = indicatorProgress * 18

                HStack(spacing: 10) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(.clear)
                            .frame(width: 8 + (activeIndex == index ? currentPageWidth : nextIndex == index ? nextPageWidth : 0), height: 8)
                            .overlay {
                                ZStack {
                                    Capsule()
                                        .fill(inActiveTint)

                                    Capsule()
                                        .fill(activeTint)
                                        .opacity(opacityEffect ? activeIndex == index ? 1 - indicatorProgress : nextIndex == index ? indicatorProgress : 0 : 1)
                                }
                            }
                    }
                }
                .frame(width: scrollViewWidth)
                .offset(x: -minX)
            }
        }
        .frame(height: 30)
    }
}
