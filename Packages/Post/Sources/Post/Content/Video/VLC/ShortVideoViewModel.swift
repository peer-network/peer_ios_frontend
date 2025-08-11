//
//  ShortVideoViewModel.swift
//  Post
//
//  Created by Artem Vasin on 04.08.25.
//

import Combine
import VLCUI
import Foundation

class ShortVideoViewModel: ObservableObject {
    @Published var seconds: Duration = .zero
    @Published var playerState: VLCVideoPlayer.State = .opening
    @Published var position: Float = 0
    @Published var totalSeconds: Duration = .zero

    let proxy: VLCVideoPlayer.Proxy = .init()

    let videoURL: URL

    var configuration: VLCVideoPlayer.Configuration {
        var configuration = VLCVideoPlayer
            .Configuration(url: videoURL)
        configuration.autoPlay = false
        configuration.replay = true
        configuration.rate = .absolute(1.0)

        return configuration
    }

    var positiveSeconds: Int {
        Int(seconds.components.seconds)
    }
    
    var negativeSeconds: Int {
        Int((totalSeconds - seconds).components.seconds)
    }

    init(videoURL: URL) {
        self.videoURL = videoURL
    }

    func onStateUpdated(_ newState: VLCVideoPlayer.State, _ playbackInformation: VLCVideoPlayer.PlaybackInformation) {
        print(newState)
        playerState = newState
    }

    func onSecondsUpdated(_ newSeconds: Duration, _ playbackInformation: VLCVideoPlayer.PlaybackInformation) {
        seconds = newSeconds
        totalSeconds = .milliseconds(playbackInformation.length)
        position = playbackInformation.position
    }
}
