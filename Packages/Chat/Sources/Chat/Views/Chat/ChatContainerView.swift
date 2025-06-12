//
//  ChatContainerView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//
import SwiftUI
import Models
import Environment
import DesignSystem

struct ChatContainerView<ViewModel: ChatViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var scrollToBottom = true
    
    @StateObject private var accountManager = AccountManager.shared
    private let title: String
    
    init(viewModel: ViewModel, title: String) {
        self.viewModel = viewModel
        self.title = title
    }
    
    var body: some View {
       
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
                    Text("Chat")
                } content: {
                    VStack(spacing: 0) {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ChatLayoutView(messages: viewModel.messages, scrollToLatest: scrollToBottom)
                                .onAppear {
                                    scrollToBottom = true
                                }
                          
                            if let user = accountManager.user?.imageURL {
                               
                                ChatInputView(
                                    profileImageURL: user,
                                    profileName: viewModel.senderName,
                                    timestamp: "",
                                    messageText: Binding(
                                        get: { viewModel.newMessage },
                                        set: { viewModel.newMessage = $0 }
                                    ),
                                    onSend: viewModel.sendMessage
                                )
                                .padding(.horizontal)
                                .background(Colors.textActive)
                            }
                        }
                    }
                 
            .toolbar(.hidden, for: .navigationBar)
            .padding(.vertical)
        }
    }
}
