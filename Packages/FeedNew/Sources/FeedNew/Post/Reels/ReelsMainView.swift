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
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ReelsView(size: size)
                .ignoresSafeArea(.container, edges: .all)
        }
        .onAppear {
//            audioManager.pause()
        }
    }
}

#Preview {
    ReelsMainView()
        .environmentObject(PostViewModel(post: .placeholderText()))
}
