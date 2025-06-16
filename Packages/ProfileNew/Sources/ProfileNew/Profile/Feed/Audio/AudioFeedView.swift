//
//  AudioFeedView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 25.05.25.
//

import SwiftUI
import FeedList
import DesignSystem
import Environment

struct AudioFeedView: View {
    @EnvironmentObject private var apiManager: APIServiceManager
    @ObservedObject var viewModel: AudioFeedViewModel

    var body: some View {
        LazyVStack(spacing: 20) {
            PostsListView(fetcher: viewModel, displayType: .list, showFollowButton: false)
        }
        .padding(.vertical, 10)
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
    }
}
