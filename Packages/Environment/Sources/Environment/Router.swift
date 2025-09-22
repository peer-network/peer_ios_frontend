//
//  Router.swift
//  Environment
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import Models

public enum RouterDestination: Hashable {
    case accountDetail(id: String)
    case postDetailsWithPost(post: Post)
    case postDetailsWithPostId(id: String)
    case settings
    case hashTag(tag: String)
    case versionHistory
    case transfer(recipient: RowUser, amount: Int)
    case changePassword
    case changeEmail
    case changeUsername
    case referralProgram
    case blockedUsers
    case deleteAccount
    case commentLikes(comment: Comment)
}

public enum FullScreenCoverDestination: Hashable, Identifiable {
    case postDetailsWithPostId(id: String)

    public var id: String {
        switch self {
            case .postDetailsWithPostId:
                return "postDetailsWithPostId"
        }
    }
}

public enum SheetDestination: Identifiable, Hashable {
    case followers(userId: String)
    case following(userId: String)
    case friends(userId: String)
    case shareImage(image: UIImage, post: Post)
    
    public var id: String {
        switch self {
            case .shareImage:
                return "shareImage"
            case .followers:
                return "followers"
            case .following:
                return "following"
            case .friends:
                return "friends"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: SheetDestination, rhs: SheetDestination) -> Bool {
        lhs.id == rhs.id
    }
}

public final class Router: ObservableObject {
    @Published public var path: [RouterDestination] = []
    @Published public var presentedSheet: SheetDestination?

    public var urlHandler: ((URL) -> OpenURLAction.Result)?
    
    public init() {}
    
    public func navigate(to destination: RouterDestination) {
        presentedSheet = nil
        path.append(destination)
    }
    
    public func handle(url: URL) -> OpenURLAction.Result {
        if url.scheme == "peer" && url.host == "hashtag",
           let tag = url.pathComponents.last {
            navigate(to: .hashTag(tag: tag))
            return .handled
        }

        if url.scheme == "peer" && url.host == "post",
           let postId = url.pathComponents.last {
            navigate(to: .postDetailsWithPostId(id: postId))
            return .handled
        }

//        if url.scheme == "https",
//           url.host?.lowercased() == "peernetwork.eu" || url.host?.lowercased() == "www.peernetwork.eu" {
//            let comps = url.pathComponents  // ["/", "post", "<id>"]
//            if comps.count >= 3, comps[1] == "post" {
//                let id = comps[2]
//                path.append(.postDetailsWithPostId(id: id))
//            }
//        }

        return urlHandler?(url) ?? .systemAction
    }

    public func emptyPath() {
        path.removeAll()
    }
}


// MARK: - Comment Likes Things

@frozen
public enum CommentLikesState {
    case loading
    case display
    case error(Error)
}

public protocol CommentLikesProviding {
    var stateLikes: CommentLikesState { get }
    var likedBy: [RowUser] { get }
    var hasMoreLikes: Bool { get }
    func fetchLikes(reset: Bool)
}
