//
//  AttachmentMainView.swift
//  PostCreation
//
//  Created by Artem Vasin on 28.05.25.
//

import SwiftUI
import DesignSystem
import PhotosUI

struct AttachmentMainView: View {
    @Binding var focusOnEditing: Bool
    @Binding var postType: PostType

    @Binding var imageStates: [ImageState]?
    @Binding var selectedPhotoItems: [PhotosPickerItem]
    @Binding var videoState: VideoState?

    @State private var isExpanded: Bool = false

    var body: some View {
        Group {
            if let imageStates, !imageStates.isEmpty {
                SelectedImagesView(imageStates: $imageStates, pickerItems: $selectedPhotoItems)
                    .padding(.horizontal, -20)
                    .onAppear {
                        postType = .photo
                    }
            } else if videoState != nil {
                SelectedVideoView(videoWithState: $videoState, showTrimmingView: $focusOnEditing) {
                    withAnimation {
                        self.videoState = nil
                    }
                }
                .onAppear {
                    postType = .video
                }
            } else {
                uploadMediaRectangle2
                    .onAppear {
                        postType = .text
                    }
            }
        }
        .onChange(of: postType) {
            isExpanded = false
        }
    }

    private var uploadMediaRectangle2: some View {
        ZStack(alignment: .bottomTrailing) {
            Text("Upload media")
                .font(.customFont(weight: .regular, style: .body))
                .foregroundStyle(Colors.whiteSecondary)
                .frame(width: getRect().height * 0.3, height: getRect().height * 0.3)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Colors.whiteSecondary, style: .init(lineWidth: 4, lineCap: .round, dash: [8, 10]))
                }

            Button {
                isExpanded.toggle()
            } label: {
                Icons.plusBold
                    .iconSize(height: 22)
                    .foregroundStyle(Colors.whitePrimary)
                    .rotationEffect(.init(degrees: isExpanded ? 45 : 0))
                    .scaleEffect(1.02)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Gradients.activeButtonBlue, in: .circle)
                    /// Scaling Effect When Expanded
                    .scaleEffect(isExpanded ? 0.9 : 1)
            }
            .buttonStyle(NoAnimationButtonStyle())
            .frame(width: 68, height: 68)
            .background {
                ZStack {
                    videoButton
                    photoButton
                }
                .frame(width: 68, height: 68)
            }
            .sensoryFeedback(.success, trigger: isExpanded)
            .animation(.snappy(duration: 0.4, extraBounce: 0), value: isExpanded)
            .offset(x: 14, y: 12)
        }
        .padding(.bottom, 12)
        .contentShape(.rect)
    }

    private var videoButton: some View {
        PostVideoPicker(videoState: $videoState) {
            Image(systemName: "video.fill")
                .font(.title3)
                .foregroundStyle(Colors.whitePrimary)
                .frame(width: 68, height: 68)
                .background(Colors.inactiveDark, in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isExpanded)
        .offset(x: isExpanded ? -offset / 2 : 0)
    }

    private var photoButton: some View {
        PostPhotoPicker(imageStates: $imageStates, selectedItems: $selectedPhotoItems) {
            Image(systemName: "camera.fill")
                .font(.title3)
                .foregroundStyle(Colors.whitePrimary)
                .frame(width: 68, height: 68)
                .background(Colors.inactiveDark, in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isExpanded)
        .offset(y: isExpanded ? -offset / 2 : 0)
    }

    private var offset: CGFloat {
        return 2 * 78 * 1.25
    }
}

fileprivate struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.snappy(duration: 0.3, extraBounce: 0), value: configuration.isPressed)
    }
}

fileprivate struct NoAnimationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
