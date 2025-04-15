//
//  ReelsMainView.swift
//  FeedNew
//
//  Created by Артем Васин on 07.02.25.
//

import SwiftUI
import Environment

struct ReelsMainView: View {
//    @SwiftUI.Environment(AudioManager.self) private var audioManager
    @EnvironmentObject private var apiManager: APIServiceManager
    @StateObject private var viewModel: VideoFeedViewModel
    
    init(viewModel: VideoFeedViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ReelsView(viewModel: viewModel, size: size)
                .ignoresSafeArea(.container, edges: .all)
        }
        .onAppear {
//            audioManager.pause()
        }
    }
}

#Preview {
    ReelsMainView(viewModel: .init(apiService: APIServiceStub(), filters: .shared, transitions: .init(openProfile: {_ in }, showComments: {_ in })))
        .environmentObject(PostViewModel(post: .placeholderText()))
}
