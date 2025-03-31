//
//  CommentDataController.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import Models
import GQLOperationsUser
import Networking
import Environment

@MainActor
final class CommentDataController: ObservableObject {
    let comment: Comment
    
    @Published public private(set) var isLiked: Bool
    @Published public private(set) var amountLikes: Int
    
    init(comment: Comment) {
        self.comment = comment
        
        isLiked = comment.isLiked
        amountLikes = comment.amountLikes
    }
    
    public func toggleLike() async {
        guard !isLiked else { return } // show a popup or just ignore..?
        guard !AccountManager.shared.isCurrentUser(id: comment.userId) else { return }
        
        withAnimation {
            isLiked = true
            amountLikes += 1
        }
        
//        do {
//            let result = try await GQLClient.shared.mutate(mutation: LikeCommentMutation(commentid: comment.id))
//            
//            guard let status = result.likeComment?.status, status == "success" else {
//                throw GQLError.missingData
//            }
//        } catch {
//            isLiked = false
//            amountLikes -= 1
//        }
    }
}
