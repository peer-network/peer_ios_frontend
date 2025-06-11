import SwiftUI
import Models
import Environment
import GQLOperationsUser

class ChatCoordinator: ObservableObject, Coordinator {
  
    // MARK: - Published Properties
    @Published var selectedChatType: ChatType = .privateChat
    @Published var privateChatViewModel: PrivateChatViewModel?
    @Published var groupChatViewModel: GroupChatViewModel?
    @Published var groupCreationViewModel: GroupCreationViewModel?
   
    @Published var isPresentingFriendSelection = false
    @Published var isPresentingGroupCreation = false
    @Published var activePeer: RowUser?
    @Published var chats: [ListChats] = []
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var subscriptionError: APIError?
    @Published var selectedChat: ListChats?
    @Published var currentChatMessages: [ChatMessage] = []
    @Published var isFetchingMessages = false
    
    // MARK: - Coordinator Properties
    var friendSelectionViewModel: FriendSelectionViewModel?
    var childCoordinators: [any Coordinator] = []
    weak var parentCoordinator: AppCoordinator?
    
    // MARK: - Subscription Management
    private var chatMessagesSubscriptionTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(parentCoordinator: AppCoordinator?) {
        self.parentCoordinator = parentCoordinator
        Task {
            await fetchChats()
        }
    }

    deinit {
        chatMessagesSubscriptionTask?.cancel()
    }
    
    
    @MainActor
    func clearChatSelection() {
            selectedChat = nil
            privateChatViewModel = nil
            groupChatViewModel   = nil
            stopChatMessagesSubscription()
        
    }

  
    
    // MARK: - Public Methods
    func start() { /* Initial setup */ }
    
    func view(for chatType: ChatType) -> AnyView {
        let filtered = chats(for: chatType)
        
        switch chatType {
        case .privateChat:
            if isLoading { return AnyView(ProgressView()) }
            if filtered.isEmpty { return AnyView(Text("No chats available").italic()) }
            
            return AnyView(
                PrivateChatListView(chats: filtered) { [weak self] chat in
                    Task { @MainActor in
                        self?.handleChatSelection(chat)
                    }
                }
                .navigationTitle("Chats")
            )
            
        case .groupChat:
            if isLoading { return AnyView(ProgressView()) }
            if filtered.isEmpty { return AnyView(Text("No group chats available").italic()) }
            
            return AnyView(
                GroupChatListView(
                    chats: filtered,
                    onChatSelected: { [weak self] chat in
                        Task { @MainActor in
                            self?.handleChatSelection(chat)
                        }
                    },
                    onAddTapped: handleAddTapped
                )
                .navigationTitle("Group Chats")
            )
        }
    }
    
    // MARK: - Chat Management
    @MainActor
    func handleChatSelection(_ chat: ListChats) {
        guard let currentUserId = AccountManager.shared.userId else { return }

        // participants mapped to lightweight `User`
        let participants = chat.chatParticipants.map {
            User(id: $0.userId, name: $0.username, image: $0.img)
        }
        guard let me = participants.first(where: { $0.id == currentUserId }) else { return }

        // Convert server messages → Message1
        let initialMessages: [Message1] = chat.chatMessages.map { m in
            let sender = participants.first(where: { $0.id == m.senderId }) ?? me
            return Message1(id: m.senderId, text: m.content,
                            isIncoming: m.senderId != currentUserId,
                            timestamp: m.createdAt ?? "",
                            sender: sender)
        }

        // ────────── Decide private vs group ──────────
        if participants.count > 2 {
            // -------- GROUP CHAT --------
            groupChatViewModel = GroupChatViewModel(
                currentUser: me,
                participants: participants, groupName: chat.name ?? "unnameed group",
                initialMessages: initialMessages,
                sendAction: { [weak self] text in
                    self?.sendMessage(chatId: chat.id, content: text) { optimistic in
                        Task { @MainActor in
                            self?.groupChatViewModel?.messages.append(optimistic)
                        }
                    }
                }
            )
            privateChatViewModel = nil
            selectedChatType     = .groupChat   // keeps ping routing correct
        } else {
            // -------- PRIVATE CHAT --------
            guard let peer = participants.first(where: { $0.id != currentUserId }) else { return }

            privateChatViewModel = PrivateChatViewModel(
                peer: peer,
                currentUser: me,
                initialMessages: initialMessages,
                refreshAction: { [weak self] in
                        guard let self else { return }
                    await self.refreshMessages(for: peer.id)
                    },
//                fetchAction: { chatId async -> [Message1] in
//                    print("fetch action called")
//                    // 1. Make the call
////                    let result = await APIServiceManager().apiService
////                                    .listChatMessages(for: chatId)
////
////                    // 2. Bail out on failure
////                    guard case .success(let payload) = result else { return [] }
//
//                    // 3. Map the payload → [Message1]
//                   // return ChatCoordinator.map(payload,
//                                        //       currentUserId: AccountManager.shared.userId)
//                },
                
                sendAction: { [weak self] text in
                    print("sendtext and id",[chat.id, text])
                    self?.sendMessage(chatId: chat.id, content: text) { optimistic in
                        Task { @MainActor in
                            self?.privateChatViewModel?.messages.append(optimistic)
                        }
                    }
                }
            )
            groupChatViewModel = nil
            selectedChatType   = .privateChat
        }

        selectedChat = chat
       // startChatMessagesSubscription(chatId: chat.id)
    }

    
    @MainActor
    func sendMessage(chatId: String, content: String, optimistic localAppend: @escaping (Message1) -> Void) {
//        let outgoing = Message1(
//            id: chatId,
//            text: content,
//            isIncoming: false,
//            timestamp: Date(),
//            sender: User(id: AccountManager.shared.userId ?? "", name: "You", image: "\(String(describing: AccountManager.shared.user?.imageURL))")
//        )
//        localAppend(outgoing)
        print("send messages calling", chatId)
        Task {
            let result = await APIServiceManager().apiService.sendChatMessage(with: chatId, content: content)
            
            switch result {
            case .success:
                await self.fetchChats()
            case .failure(let error):
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    // MARK: - Subscription Handling
//    @MainActor
//    func startChatMessagesSubscription(chatId: String) {
//        stopChatMessagesSubscription()
//
//        chatMessagesSubscriptionTask = Task { [weak self] in
//            guard let self = self else { return }
//
//            let stream = APIServiceManager()
//                .apiService
//                .subscribeToChatMessages(chatId: chatId)
//
//            do {
//                for try await payload in stream {
//                    await self.handleSubscriptionPing(payload, forChatId: chatId)
//                }
//            } catch {
//                await MainActor.run {
//                    self.subscriptionError = .streamError(error: error)
//                }
//            }
//        }
//    }
    
   

    @MainActor
    private func handleSubscriptionPing(
        _ data: GetChatMessagesSubscription.Data,
        forChatId chatId: String
    ) async {
        let result = await APIServiceManager()
            .apiService
            .listChatMessages(for: chatId)

        guard case .success(let list) = result else { return }
        guard let currentUserId = AccountManager.shared.userId else { return }

        
        let me = User(id: currentUserId, name: "Me", image: "\(AccountManager.shared.user?.imageURL)" ?? nil)
            let peer = User(id: "peer", name: "Peer", image: nil)

        let latest = list.messages.map { msg -> Message1 in
            print("incomingmessagge", list)
            let incoming = msg.userid != currentUserId
            return Message1(
                id: msg.userid,
                text: msg.content,
                isIncoming: incoming,
                timestamp: msg.createdAt ?? "", // Parse from msg.createdAt if needed
                sender: incoming ? peer : me
            )
        }
        print("selectedChatType", selectedChatType)

        if selectedChatType == .privateChat {
            privateChatViewModel?.messages = latest
        } else {
            groupChatViewModel?.messages = latest
        }
    }

    @MainActor
    func stopChatMessagesSubscription() {
        chatMessagesSubscriptionTask?.cancel()
        chatMessagesSubscriptionTask = nil
    }
    
    // MARK: - Data Fetching
    @MainActor
    private func fetchChats() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await APIServiceManager().apiService.listChats()
        switch result {
        case .success(let fetchedChats): chats = fetchedChats
        case .failure(let apiError): error = apiError
        }
    }
    
    @MainActor
    func refreshMessages(for chatId: String) async {
        isFetchingMessages = true
        defer { isFetchingMessages = false }
print("chatId", chatId)
        let result = await APIServiceManager().apiService.listChatMessages(for: chatId)
        print("listddd", result)
        guard case .success(let list) = result else {
            
            if case .failure(let err) = result {
                self.error = err
            }
            return
        }

        guard let currentUserId = AccountManager.shared.userId else { return }
        let me = User(id: currentUserId, name: "Me", image: "\(AccountManager.shared.user?.imageURL)" ?? nil)
        let peer = User(id: "peer", name: "Peer", image: nil)

        let latest = list.messages.map { msg -> Message1 in
            let incoming = msg.userid != currentUserId
            return Message1(
                id: msg.userid,
                text: msg.content,
                isIncoming: incoming,
                timestamp: msg.createdAt ?? "",
                sender: incoming ? peer : me
            )
        }

        if selectedChatType == .privateChat {
            privateChatViewModel?.messages = latest
        } else {
            groupChatViewModel?.messages = latest
        }
    }

    
    @MainActor
    func fetchMessages(for chatId: String) async {
        isFetchingMessages = true
        defer { isFetchingMessages = false }
        
        let result = await APIServiceManager().apiService.listChatMessages(for: chatId)
        switch result {
        case .success(let data):
            print("Received message data:", data)
        case .failure(let error):
            self.error = error
        }
    }
    
    // MARK: - Friend Selection
    @MainActor
    func handleAddTapped() {
        let apiManager = APIServiceManager()
        let isGroup = selectedChatType == .groupChat
        friendSelectionViewModel = FriendSelectionViewModel(
            userId: AccountManager.shared.userId ?? "",
            apiService: apiManager.apiService,
            allowsMultipleSelection: isGroup
        )
        isPresentingFriendSelection = true
    }
    
    @MainActor
    func handleFriendSelectionCompletion(_ selected: [RowUser]) {
        isPresentingFriendSelection = false
        
        switch selectedChatType {
        case .privateChat:
            // Private chat supports only one selection
            guard let peer = selected.first else { return }
            print("peerdata", peer)
            // Try to find existing 1-on-1 chat with the selected user
            if let existingChat = chats.first(where: { chat in
                chat.chatParticipants.contains(where: { $0.userId == peer.id }) &&
                chat.chatParticipants.count == 2
            }) {
                print("existingChat", existingChat)
                handleChatSelection(existingChat)
            } else {
                print("existingChat1", peer)
                
                Task { [weak self] in
                    guard let self else { return }
                    
                    // ① create (or get) the 1-on-1 chat on the server
                    let createResult = await APIServiceManager()
                        .apiService
                        .createChat(name: "",
                                    recipients: [peer.id],
                                    image: nil)
                    
                    // ② bail out on failure
                    guard case .success(let chatId) = createResult else {
                        if case .failure(let err) = createResult {
                            await MainActor.run { self.error = err }
                        }
                        return
                    }
                    
                    // ③ fetch the brand-new chat row so we have participants/messages
                    let listResult = await APIServiceManager()
                        .apiService
                        .listChats()
                    
                    guard case .success(let allChats) = listResult,
                          let newChat = allChats.first(where: { $0.id == chatId })
                    else { return }
                    
                    // ④ insert into local array (so it shows in the list)
                    await MainActor.run {
                        if !self.chats.contains(where: { $0.id == chatId }) {
                            self.chats.insert(newChat, at: 0)
                        }
                        
                        // ⑤ reuse existing flow
                        self.handleChatSelection(newChat)
                    }
                }
                
            }
            
        case .groupChat:
            guard selected.count >= 2 else { return }

            // 1️⃣  SHOW the sheet (only here)
            isPresentingGroupCreation = true

            groupCreationViewModel = GroupCreationViewModel(
                initialMembers: selected,
                onAddAccounts: { [weak self] in
                    self?.isPresentingFriendSelection = true
                },
                onCreateSuccess: { [weak self] in        // ← path if VM calls its own success
                    self?.closeGroupCreationOverlay()
                },
                onCreateChat: { [weak self] name, ids async -> Result<String, APIError> in
                    guard let self else { return .failure(.missingData) }

                    // ── create chat on server ─────────────────────────────
                    let res = await self.createGroupChat(name: name, memberIds: ids)
                    guard case .success(let chatId) = res else { return res }

                    // ── fetch chat row ───────────────────────────────────
                    let listRes = await APIServiceManager().apiService.listChats()
                    guard case .success(let all) = listRes,
                          let newChat = all.first(where: { $0.id == chatId }) else { return res }

                    // ── update list & dismiss sheet on main thread ───────
                    await MainActor.run {
                        if !self.chats.contains(where: { $0.id == chatId }) {
                            self.chats.insert(newChat, at: 0)
                        }
                        self.closeGroupCreationOverlay()      // 🔑 hide sheet
                    }
                    return res
                }
            )

        }
    }

    @MainActor
    private func closeGroupCreationOverlay() {
        isPresentingGroupCreation = false          // hide overlay
        groupCreationViewModel   = nil             // prevent re-render
        groupChatViewModel       = nil             // stay on list
        privateChatViewModel     = nil
    }

    
        @MainActor
        func createGroupChat(name: String, memberIds: [String]) async -> Result<String, APIError> {
            print("ENTERED createGroupChat")
            let result = await APIServiceManager().apiService.createChat(
                name: name,
                recipients: memberIds,
                image: nil
            )
            print("GOT RESULT FROM API")
            print("postdataresponse",  [name, memberIds,result])
            if case .success(let chatId) = result {
                await fetchChats()
            }
            return result
        }
    private func chats(for type: ChatType) -> [ListChats] {
        type == .privateChat
            ? chats.filter { $0.chatParticipants.count <= 2 }
            : chats.filter { $0.chatParticipants.count > 2 }
    }
}
