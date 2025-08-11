//
//  VideoFeedView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 27.07.25.
//

import SwiftUI
import Environment
import DesignSystem
import FeedList

struct VideoFeedView: View {
    @EnvironmentObject private var apiManager: APIServiceManager
    @ObservedObject var viewModel: VideoFeedViewModel

    private var columns: [GridItem] {
        [
            GridItem(.fixed(getRect().width / 3 - 2 / 3), spacing: 1),
            GridItem(.fixed(getRect().width / 3 - 2 / 3), spacing: 1),
            GridItem(.fixed(getRect().width / 3 - 2 / 3), spacing: 1)
        ]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 1) {
            PostsListView(fetcher: viewModel, displayType: .grid, showFollowButton: false)
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
    }
}
