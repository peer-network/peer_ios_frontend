//
//  RegularFeedView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 25.05.25.
//

import SwiftUI
import Environment
import DesignSystem
import FeedList

struct RegularFeedView: View {
    @EnvironmentObject private var apiManager: APIServiceManager
    @ObservedObject var viewModel: RegularFeedVM

    var body: some View {
        LazyVStack(spacing: 20) {
            PostsListView(fetcher: viewModel, displayType: .list, showFollowButton: false)
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
    }
}
