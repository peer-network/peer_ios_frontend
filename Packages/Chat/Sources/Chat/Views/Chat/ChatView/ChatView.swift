//
//  ChatView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI
import Models
import Environment
import DesignSystem

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
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
                    Text("Chat")
        } content: {
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
        ZStack {
            Colors.textActive
                .ignoresSafeArea()
                .onTapGesture {
                    coordinator.isPresentingFriendSelection = false
                }

            if let viewModel = coordinator.friendSelectionViewModel {
                FriendSelectionView(
                    viewModel: viewModel,
                    isGroupChat: coordinator.selectedChatType == .groupChat,
                    onDone: coordinator.handleFriendSelectionCompletion,
                    onCreateGroupChat: { name, memberIds async -> Result<String, APIError> in
                        return await coordinator.createGroupChat(name: name, memberIds: memberIds)
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
    }


//    private var groupCreationOverlay: some View {
//        Color.black.opacity(0.3)
//            .ignoresSafeArea()
//            .overlay {
//                if let viewModel = coordinator.groupCreationViewModel {
//                    GroupCreationView(vm: viewModel)
//                }
//            }
//    }
    
    private var groupCreationOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                if let viewModel = coordinator.groupCreationViewModel {
                    GroupCreationView(vm: viewModel, onCreateSuccess: {
                        coordinator.closeGroupCreationOverlay()
                    })
                    .transition(.move(edge: .bottom))
                }
            }
            .zIndex(1) // Lower than friend selection
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
