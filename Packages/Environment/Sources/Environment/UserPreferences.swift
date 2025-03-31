//
//  UserPreferences.swift
//  Environment
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI

public final class UserPreferences: ObservableObject {
    private class Storage {
        @AppStorage("preferred_browser") var preferredBrowser: PreferredBrowser = .inAppSafari
        @AppStorage("reader_view") public var inAppBrowserReaderView = false
        
        @AppStorage("show_tab_label") var showTabLabel = true
        
        @AppStorage("haptic_tab") var hapticTabSelectionEnabled = true
        @AppStorage("haptic_feed") var hapticFeedEnabled = true
        @AppStorage("haptic_button_press") var hapticButtonPressEnabled = true
        
        @AppStorage("autoplay_video") public var autoPlayVideo = true
        @AppStorage("mute_video") public var muteVideo = true
        
        @AppStorage("collapse-long-posts") public var collapseLongPosts = true
    }
    
    private let storage = Storage()
    
    public static let shared = UserPreferences()
    
    @Published public var preferredBrowser: PreferredBrowser {
        didSet {
            storage.preferredBrowser = preferredBrowser
        }
    }
    
    @Published public var inAppBrowserReaderView: Bool {
        didSet {
            storage.inAppBrowserReaderView = inAppBrowserReaderView
        }
    }
    
    @Published public var showTabLabel: Bool {
        didSet {
            storage.showTabLabel = showTabLabel
        }
    }
    
    @Published public var hapticTabSelectionEnabled: Bool {
        didSet {
            storage.hapticTabSelectionEnabled = hapticTabSelectionEnabled
        }
    }
    
    @Published public var hapticFeedEnabled: Bool {
        didSet {
            storage.hapticFeedEnabled = hapticFeedEnabled
        }
    }
    
    @Published public var hapticButtonPressEnabled: Bool {
        didSet {
            storage.hapticButtonPressEnabled = hapticButtonPressEnabled
        }
    }
    
    @Published public var collapseLongPosts: Bool {
        didSet {
            storage.collapseLongPosts = collapseLongPosts
        }
    }
    
    @Published public var autoPlayVideo: Bool {
        didSet {
            storage.autoPlayVideo = autoPlayVideo
        }
    }
    
    @Published public var muteVideo: Bool {
        didSet {
            storage.muteVideo = muteVideo
        }
    }
    
    private init() {
        preferredBrowser = storage.preferredBrowser
        inAppBrowserReaderView = storage.inAppBrowserReaderView
        showTabLabel = storage.showTabLabel
        hapticTabSelectionEnabled = storage.hapticTabSelectionEnabled
        hapticFeedEnabled = storage.hapticFeedEnabled
        hapticButtonPressEnabled = storage.hapticButtonPressEnabled
        collapseLongPosts = storage.collapseLongPosts
        autoPlayVideo = storage.autoPlayVideo
        muteVideo = storage.muteVideo
    }
}
