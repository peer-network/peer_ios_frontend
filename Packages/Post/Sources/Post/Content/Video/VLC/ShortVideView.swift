//
//  ShortVideView.swift
//  Post
//
//  Created by Artem Vasin on 04.08.25.
//

import SwiftUI
import VLCUI

struct ShortVideoView: View {
    @ObservedObject var postVM: PostViewModel

    @StateObject private var playerVM: ShortVideoViewModel

    private let size: CGSize

    init(postVM: PostViewModel, size: CGSize) {
        self.postVM = postVM
        self.size = size

        _playerVM = .init(wrappedValue: .init(videoURL: postVM.post.mediaURLs.first!))
    }

    var body: some View {
        GeometryReader { geo in
            if let videoURL = postVM.post.mediaURLs.first {
                VLCVideoPlayer(configuration: playerVM.configuration)
                    .proxy(playerVM.proxy)
                    .onStateUpdated(playerVM.onStateUpdated)
                    .onSecondsUpdated(playerVM.onSecondsUpdated)
                    .frame(width: size.width, height: size.height, alignment: .center)
                    .onDisappear {
                        print("onDisappear")
                    }
                    .onAppear {
                        print("onAppear")
                    }
                    .overlay {
                        Text("\(playerVM.playerState)")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    .onTapGesture(count: 1) {
                        if playerVM.playerState == .playing {
                            playerVM.proxy.pause()
                        } else {
                            playerVM.proxy.play()
                        }
                    }
            }
        }
    }
}
