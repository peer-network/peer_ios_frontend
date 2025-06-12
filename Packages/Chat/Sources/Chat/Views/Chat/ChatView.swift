//
//  ChatView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI
import Models
import Environment

public struct ChatView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    
    public init() {}
    
    public var body: some View {
            Group {
                if let chatCoordinator = appCoordinator.currentCoordinator as? ChatCoordinator {
                    MainChatView(coordinator: chatCoordinator)
                } else {
                    ProgressView()
                        .onAppear {
                            appCoordinator.start()
                        }
                }
            }
        }
    
}

// MARK: - Main Chat Container View
private struct MainChatView: View {
    @ObservedObject var coordinator: ChatCoordinator
    @StateObject private var accountManager = AccountManager.shared
    
    var body: some View {
        ZStack {
            chatContentView
            
            if coordinator.isPresentingFriendSelection {
                friendSelectionOverlay
            }
            
            if coordinator.isPresentingGroupCreation {
                groupCreationOverlay
            }
        }
        .navigationDestination(
            isPresented: Binding(
                get: { coordinator.selectedChat != nil },
                set: { if !$0 { coordinator.clearChatSelection() } }
            )
        ) {
            chatDestinationView
        }
        .alert("Error",
               isPresented: Binding(
                get: { coordinator.error != nil },
                set: { if !$0 { coordinator.error = nil } }
               ),
               presenting: coordinator.error) { error in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    // MARK: - Subviews
    
    private var chatContentView: some View {
        VStack(spacing: 0) {
            ChatToggleView(
                selectedTab: $coordinator.selectedChatType,
                onAddTapped: coordinator.handleAddTapped
            )
            .padding(.horizontal)
            .padding(.top)
            
            coordinator.view(for: coordinator.selectedChatType)
            
            Spacer()
        }
    }
    
    private var friendSelectionOverlay: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .onTapGesture {
                coordinator.isPresentingFriendSelection = false
            }
            .overlay {
                if let viewModel = coordinator.friendSelectionViewModel {
                    FriendSelectionView(
                        viewModel: viewModel,
                        isGroupChat: coordinator.selectedChatType == .groupChat,
                        onDone: coordinator.handleFriendSelectionCompletion,
                        onCreateGroupChat: { name, memberIds async -> Result<String, APIError> in
                              //  guard let self = self else { return .failure(.missingData) }
                                return await coordinator.createGroupChat(name: name, memberIds: memberIds)
                            }

                    )
                    .frame(
                        width: UIScreen.main.bounds.width * 0.8
                    )
                    .frame(maxHeight: .infinity)
                }
            }
    }
    
    private var groupCreationOverlay: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay {
                if let viewModel = coordinator.groupCreationViewModel {
                    GroupCreationView(vm: viewModel)
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                }
            }
    }
    
    
    
    @ViewBuilder
    private var chatDestinationView: some View {
        if let privateChatVM = coordinator.privateChatViewModel {
            PrivateChatView(viewModel: privateChatVM)
        } else if let groupChatVM = coordinator.groupChatViewModel {
            GroupChatView(viewModel: groupChatVM)
        } else {
            ProgressView()
        }
    }
}

// MARK: - Preview
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
