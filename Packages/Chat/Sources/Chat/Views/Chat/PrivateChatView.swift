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

//struct PrivateChatView: View {
//    @ObservedObject var viewModel: PrivateChatViewModel
//    @StateObject private var accountManager = AccountManager.shared
//    
//    var body: some View {
//       
//        VStack {
//            ChatLayoutView(messages: viewModel.messages)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//           
//            if let user = AccountManager.shared.user?.imageURL {
//                ChatInputView(
//                    profileImageURL: user,
//                    profileName: viewModel.peer.name,
//                    messageText: $viewModel.newMessage,
//                    onSend: {
//                        viewModel.sendMessage()
//                    }
//                )
//                .padding(.horizontal)
//                .onAppear() {
//                    print("messagefinis", viewModel.messages)
//                }
//            }
//        }
//        .navigationTitle(viewModel.peer.name)
//        .padding(.vertical)
//    }
//}
