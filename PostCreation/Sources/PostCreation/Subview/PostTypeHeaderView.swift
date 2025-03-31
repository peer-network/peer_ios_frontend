//
//  PostTypeHeaderView.swift
//  PostCreation
//
//  Created by Артем Васин on 13.02.25.
//

import SwiftUI
import Models
import DesignSystem

struct PostTypeHeaderView: View {
    @Binding var selectedType: Post.ContentType

    var body: some View {
        HStack(spacing: 0) {
            buttonView(type: .image)

            buttonView(type: .video)

            buttonView(type: .text)

            buttonView(type: .audio)
        }
        .font(.customFont(weight: .regular, size: .body))
        .foregroundStyle(Color.white)
        .padding(10)
        .background(Color.backgroundDark)
        .animation(nil, value: selectedType)
    }

    private func buttonView(type: Post.ContentType) -> some View {
        Button {
//            withAnimation {
                selectedType = type
//            }
        } label: {
            HStack(spacing: 10) {
                if selectedType == type {
                    icon(type: type)
                }

                Text(title(type: type))
                    .bold(selectedType == type)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func title(type: Post.ContentType) -> String {
        switch type {
            case .text:
                "text"
            case .image:
                "photo"
            case .video:
                "video"
            case .audio:
                "audio"
        }
    }

    @ViewBuilder
    private func icon(type: Post.ContentType) -> some View {
        switch type {
            case .text:
                Icons.a
                    .iconSize(height: 19)
            case .image:
                Icons.camera
                    .iconSize(height: 19)
            case .video:
                Icons.play
                    .iconSize(height: 19)
            case .audio:
                Icons.musicBars
                    .iconSize(height: 19)
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundDark
            .ignoresSafeArea()

        PostTypeHeaderView(selectedType: .constant(.image))
    }
}
