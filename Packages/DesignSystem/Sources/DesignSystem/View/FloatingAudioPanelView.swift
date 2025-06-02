//
//  FloatingAudioPanelView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 27.03.25.
//

import SwiftUI
import Environment

public struct FloatingAudioPanelView: View {
    @EnvironmentObject private var audioManager: AudioSessionManager

    public init() {}

    public var body: some View {
        if let currentItem = audioManager.currentPlayerObject {
            HStack(spacing: 0) {
                ProfileAvatarView(url: currentItem.pictureURL, name: currentItem.title, config: .audioPlayer, ignoreCache: true)

                Spacer()
                    .frame(width: 10)

                VStack(alignment: .leading, spacing: 0) {
                    Text(currentItem.title)
                        .font(.customFont(weight: .boldItalic, style: .callout))
                    Text(currentItem.subtitle)
                        .font(.customFont(weight: .regular, style: .caption1))
                }
                .lineLimit(1)

                Spacer()
                    .frame(minWidth: 10)
                    .layoutPriority(-1)

                Button {
                    audioManager.togglePlayPause()
                } label: {
                    if audioManager.isPlaying {
                        Icons.pause
                            .iconSize(height: 25)
                    } else {
                        Icons.play
                            .iconSize(height: 25)
                    }
                }

                Spacer()
                    .frame(width: 30)

                Button {
                    audioManager.stop()
                } label: {
                    Icons.xBold
                        .iconSize(height: 14)
                }
            }
            .foregroundStyle(Colors.whitePrimary)
            .padding(.vertical, 6)
            .overlay(alignment: .bottom) {
                ZStack {
                    Capsule()
                        .frame(height: 2)
                        .foregroundStyle(Colors.whitePrimary)

                    Capsule()
                        .fill(Colors.hashtag)
                        .frame(height: 2)
                        .mask {
                            Rectangle()
                                .scale(
                                    x: audioManager.duration > 0 ? CGFloat(audioManager.currentTime) / CGFloat(audioManager.duration) : 0,
                                    anchor: .leading
                                )
                        }
                }
            }
            .padding(.horizontal, 10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .contentShape(Rectangle())
            .transition(.opacity.combined(with: .scale))
            .animation(.spring(), value: audioManager.currentPlayerObject)
    }
}
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        VStack {
            FloatingAudioPanelView()

            FloatingAudioPanelView()
        }
    }
    .environmentObject(AudioSessionManager.shared)
}
