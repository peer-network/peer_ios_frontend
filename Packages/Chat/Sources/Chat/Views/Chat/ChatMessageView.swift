//
//  ChatMessageView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//

import SwiftUI
import Environment

struct ChatMessageView: View {
    @ObservedObject var viewModel: ChatViewModel
    @StateObject private var accountManager = AccountManager.shared
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ChatLayoutView(messages: viewModel.messages)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .refreshable {
//                        await viewModel.messages // Make refreshMessages() async
//                       }
                
                if let userImage = accountManager.user?.imageURL {
                    ChatInputView(
                        profileImageURL: userImage,
                        profileName: viewModel.senderName,
                        messageText: $viewModel.newMessage,
                        onSend: viewModel.sendMessage
                    )
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(viewModel.displayTitle)
        .padding(.vertical)
    }
}
