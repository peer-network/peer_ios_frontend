//
//  ChatContainerView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//
import SwiftUI
import Models
import Environment

struct ChatContainerView<ViewModel: ChatViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    
    @StateObject private var accountManager = AccountManager.shared
    private let title: String
    
    init(viewModel: ViewModel, title: String) {
        self.viewModel = viewModel
        self.title = title
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ChatLayoutView(messages: viewModel.messages)
                   // .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if let user = accountManager.user?.imageURL {
                    ChatInputView(
                        profileImageURL: user,
                        profileName: viewModel.senderName,
                        //messageText: $viewModel.newMessage,
                        messageText: Binding(
                            get: { viewModel.newMessage },
                            set: { viewModel.newMessage = $0 }
                        ),
                        onSend: viewModel.sendMessage
                    )
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(title)
        .padding(.vertical)
        .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task { await viewModel.refreshMessages() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
    }
}
