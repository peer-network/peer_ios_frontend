//
//  AudioSessionManager.swift
//  Environment
//
//  Created by Artem Vasin on 28.03.25.
//

import AVFoundation
import Combine

@MainActor
public final class AudioSessionManager: ObservableObject {
    public static let shared = AudioSessionManager()

    public struct PlayerObject: Equatable {
        public let title: String
        public let subtitle: String
        public let pictureURL: URL?
        public let url: URL

        public init(title: String, subtitle: String, pictureURL: URL?, url: URL) {
            self.title = title
            self.subtitle = subtitle
            self.pictureURL = pictureURL
            self.url = url
        }
    }

    @Published public private(set) var isSetup: Bool = false
    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var currentTime: Double = 0
    @Published public private(set) var duration: Double = 0
    @Published public private(set) var currentPlayerObject: PlayerObject?

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    private let session = AVAudioSession.sharedInstance()

    // Track if we're in video feed (should pause audio)
    @Published public var isInRestrictedView: Bool = false {
        didSet {
            if isInRestrictedView {
                pause()
            } else if currentPlayerObject != nil {
                play()
            }
        }
    }

    private init() {}

    public func start(item: PlayerObject) {
        // If same item is already playing, just toggle play/pause
        if let current = currentPlayerObject, current.url == item.url {
            togglePlayPause()
            return
        }

        stop()

        currentPlayerObject = item
        setupPlayer(with: item)
        configureSession()
        play()
    }

    public func stop() {
        pause()
        currentPlayerObject = nil

        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }

        currentTime = 0

        player?.seek(to: .zero)
        player?.replaceCurrentItem(with: nil)
        deactivateSession()
    }

    public func pause() {
        guard isPlaying else { return }
        player?.pause()
        isPlaying = false
    }

    public func play() {
        guard !isPlaying else { return }

        if currentTime == duration {
            seek(to: 0)
        }

        player?.play()
        isPlaying = true
    }

    public func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    public func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }

    private func setupPlayer(with item: PlayerObject) {
        player = AVPlayer(url: item.url)
        player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible

        player?.currentItem?.errorLog()?.events.forEach { event in
            print("Player error: \(event.errorComment ?? "Unknown error")")
        }

        // Observe duration
        player?.currentItem?.publisher(for: \.duration)
            .sink { [weak self] duration in
                self?.duration = duration.isNumeric ? duration.seconds : 0
            }
            .store(in: &cancellables)

        setupTimeObserver()
    }

    private func setupTimeObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let currentSeconds = time.seconds
            if self.currentTime != time.seconds {
                self.currentTime = currentSeconds
            }
        }
    }

    private func configureSession() {
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            print("Failed to configure audio session: \(error)")
            print(error.localizedDescription)
        }
    }

    private func deactivateSession() {
        do {
            try session.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
}
