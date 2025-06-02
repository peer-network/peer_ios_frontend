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

    var body: some View {
        pageContentView(states: imageStates ?? [])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 7)
    }

    @ViewBuilder
    private func pageContentView(states: [ImageState]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(states, id: \.id) { imageState in
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
                    .overlay(alignment: .top) {
                        Button {
                            withAnimation {
                                pickerItems.removeAll(where: { $0.itemIdentifier == imageState.pickerItem?.itemIdentifier })
                                imageStates?.removeAll(where: { $0.id == imageState.id })
                            }
                        } label: {
                            Text("remove")
                                .font(.customFont(style: .footnote))
                                .foregroundStyle(Colors.whitePrimary)
                                .padding(10)
                                .contentShape(.rect)
                                .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 4)
                        }
                    }
                    .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 4)
                    .padding(.horizontal, 10)
                    .containerRelativeFrame(.horizontal)
                }

                if states.count < 5 {
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
        .safeAreaPadding(.horizontal, 20)
    }

    private var loadingPlaceholder: some View {
        ProgressView()
            .controlSize(.large)
            .frame(width: getRect().width - 60, height: getRect().width - 60)
            .background(Colors.inactiveDark)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: getRect().width - 60, height: getRect().width - 60)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func imageErrorView(_ error: Error) -> some View {
        Text("Error: \(error.localizedDescription)")
            .frame(width: getRect().width - 60, height: getRect().width - 60)
            .background(Colors.inactiveDark)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var addPhotoButton: some View {
        Text("Choose photo")
            .font(.customFont(style: .callout))
            .foregroundStyle(Colors.whiteSecondary)
            .frame(width: getRect().width - 60, height: getRect().width - 60)
            .background(Colors.inactiveDark)
            .clipShape(RoundedRectangle(cornerRadius: 24))
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
