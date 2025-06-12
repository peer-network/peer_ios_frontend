import SwiftUI

struct User: Identifiable, Equatable {
    let id: String
    let name: String
    let image: String?
}

struct Message1: Identifiable {
    let id: String
    let text: String
    let isIncoming: Bool
    let timestamp: String
    let sender: User
}

final class PrivateChatViewModel: ObservableObject {
    let peer: User
    let currentUser: User
    private let sendAction: (String) -> Void
    @StateObject private var appCoordinator = AppCoordinator()
   // private let fetchAction: (_ chatId: String) async -> [Message1]
    private let refreshAction: () async -> Void

    
    @Published var messages: [Message1]
    @Published var newMessage = ""
    @Published var isLoading = false
    
    init(peer: User, currentUser: User, initialMessages: [Message1] = [],refreshAction: @escaping () async -> Void, sendAction: @escaping (String) -> Void) {
        self.peer = peer
        self.currentUser = currentUser
        self.messages = initialMessages
        self.sendAction  = sendAction
        self.refreshAction = refreshAction
       // self.fetchAction = fetchAction
    }
    

    
    @MainActor
        func sendMessage() {
            guard !newMessage.isEmpty else { return }
            let text = newMessage
            newMessage = ""
            
            // 1️⃣ Optimistic append
            let outgoing = Message1(
                id: currentUser.id,
                text: text,
                isIncoming: false,
                timestamp: Date().formattedWithMicroseconds,
                sender: currentUser
            )
            messages.append(outgoing)
            
            // 2️⃣ Delegate network work to coordinator
            sendAction(text)
        }
}
extension PrivateChatViewModel: ChatViewModelProtocol {
    var id: String {
        return peer.id
    }
    
    func refreshMessages() async {
        print("refresh called")
        await refreshAction()
    }
    
    
    
    var senderName: String {
        return peer.name
    }
}
