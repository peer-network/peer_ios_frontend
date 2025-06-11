//
//  ChatAvatarView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//


import SwiftUI
import Models
import Environment

struct ChatAvatarView: View {
    let chat: ListChats
    let isGroupChat: Bool
    
    var body: some View {
        if isGroupChat {
            groupAvatar
        } else {
            privateChatAvatar
        }
    }
    
    private var groupAvatar: some View {
        Group {
            if let url = chat.imageURL {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private var privateChatAvatar: some View {
        Group {
            if let peer = chat.chatParticipants.first(where: { $0.userId != AccountManager.shared.userId }),
               let url = peer.imageURL {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
    
    private var placeholderView: some View {
        Color.gray.opacity(0.3)
    }
}
