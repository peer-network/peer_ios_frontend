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
                            ChatLayoutView(messages: viewModel.messages)
                                // Give bottom padding to avoid overlap with input
                                //.padding(.bottom, 70) // ~height of input view + some buffer
                                .edgesIgnoringSafeArea(.bottom)
//                            let formatter = DateFormatter()
//                            formatter.dateStyle = .medium
//                            formatter.timeStyle = .short
//                            let formattedDate = DateFormatter(.string(from: Date())
                          
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
                                //.frame(height: 60)  // fixed height matching your input view design
                                .padding(.horizontal)
                                .background(Colors.textActive)  // optionally a background color
                            }
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarTrailing) {
//                            Button {
//                                Task { await viewModel.refreshMessages() }
//                            } label: {
//                                Image(systemName: "arrow.clockwise")
//                            }
//                            .disabled(viewModel.isLoading)
//                        }
//                    }

            .toolbar(.hidden, for: .navigationBar)
            //.navigationTitle(title)
            .padding(.vertical)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        Task { await viewModel.refreshMessages() }
//                    } label: {
//                        Image(systemName: "arrow.clockwise")
//                    }
//                    .disabled(viewModel.isLoading)
//                }
//            }
        }
    }
}
