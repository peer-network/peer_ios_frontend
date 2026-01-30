//
//  Router.swift
//  Environment
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import Foundation
import Models

public enum RouterDestination: Hashable {
    case accountDetail(id: String)
    case postDetailsWithPost(post: Post)
    case postDetailsWithPostId(id: String)
    case settings
    case hashTag(tag: String)
    case versionHistory
    case transfer(recipient: RowUser, amount: Int)
    case transferV2(balance: Foundation.Decimal)
    case transferSummary(balance: Foundation.Decimal, recipient: RowUser, amount: Foundation.Decimal, fees: TransferFeesModel, message: String?)
    case changePassword
    case changeEmail
    case changeUsername
    case referralProgram
    case blockedUsers
    case deleteAccount
    case commentLikes(comment: Comment)
    
    case promotePost(flowID: UUID, step: PromotePostStep)
    
    case adsHistoryOverview
    case adsHistoryDetails(ad: SingleAdStats)

    case search(type: SearchType)
}

public enum PromotePostStep: Hashable {
    case config
    case checkout
}

public enum SearchType: String {
    case none
    case username = "@username"
    case tag = "#tag"
    case title = "Title"

    public var prefix: String {
        switch self {
            case .username:
                return "@"
            case .tag:
                return "#"
            default:
                return ""
        }
    }
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
    @Published public var path = NavigationPath()
    @Published public var presentedSheet: SheetDestination?
    
    // Type-erased storage for app-owned flow objects (ShopPurchaseFlow, etc.)
    private var objectStore: [UUID: AnyObject] = [:]
    
    public var urlHandler: ((URL) -> OpenURLAction.Result)?
    
    public init() {}
    
    public func navigate<T: Hashable>(to destination: T) {
        presentedSheet = nil
        path.append(destination)
    }
    
    public func handle(url: URL) -> OpenURLAction.Result {
        if url.scheme == "peer" && url.host == "hashtag",
           let tag = url.pathComponents.last {
            navigate(to: RouterDestination.hashTag(tag: tag))
            return .handled
        }
        
        if url.scheme == "peer" && url.host == "post",
           let postId = url.pathComponents.last {
            navigate(to: RouterDestination.postDetailsWithPostId(id: postId))
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
    
    public func pop(amount: Int = 1) {
        guard !path.isEmpty, path.count >= amount else { return }
        path.removeLast(amount)
    }
    
    public func emptyPath() {
        path = NavigationPath()
    }
    
    // MARK: - Object Store (type-erased)
    
    public func store(_ object: AnyObject, id: UUID) {
        objectStore[id] = object
    }
    
    public func object(id: UUID) -> AnyObject? {
        objectStore[id]
    }
    
    public func removeObject(id: UUID) {
        objectStore[id] = nil
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
