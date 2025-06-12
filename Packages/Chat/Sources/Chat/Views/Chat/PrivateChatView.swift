//
//  PrivateChatView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI
import Environment

struct PrivateChatView: View {
    @ObservedObject var viewModel: PrivateChatViewModel
    
    var body: some View {
        ChatContainerView(
            viewModel: viewModel,
            title: viewModel.peer.name
        )
    }
}
