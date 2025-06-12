//
//  GroupChatView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI
import Environment

struct GroupChatView: View {
    @ObservedObject var viewModel: GroupChatViewModel
    
    var body: some View {
        ChatContainerView(
            viewModel: viewModel,
            title: viewModel.groupName
        )
    }
}

