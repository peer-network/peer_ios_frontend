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

//struct GroupChatView: View {
//    @ObservedObject var viewModel: GroupChatViewModel
//    @StateObject private var accountManager = AccountManager.shared           // optional
//
//    var body: some View {
//        VStack {
//            if viewModel.isLoading {
//                ProgressView()
//            } else {
//                // ───────── Messages (ChatLayout) ─────────
//                ChatLayoutView(messages: viewModel.messages)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                // ───────── Composer ─────────
//                if let user = AccountManager.shared.user?.imageURL {
//
//                    ChatInputView(
//                        profileImageURL: user,
//                        profileName: viewModel.currentUser.name,  // 👈 use current user
//                        messageText: $viewModel.newMessage,       // 👈 binding!
//                        onSend: {
//                            viewModel.sendMessage()
//                        }
//                    )
//                    .padding(.horizontal)
//                }
//            }
//        }
//        .navigationTitle(viewModel.groupName)
//        .padding(.vertical)   // outer padding
//    }
//}
