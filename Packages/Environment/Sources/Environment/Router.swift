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
    case settings
    case hashTag(tag: String)
    case versionHistory
}

public enum SheetDestination: Identifiable, Hashable {
    case followers(users: [RowUser])
    case following(users: [RowUser])
    case friends(users: [RowUser])
    case comments(post: Post, isBackgroundWhite: Bool)
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
            case .comments:
                return "comments"
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
        urlHandler?(url) ?? .systemAction
    }

    public func emptyPath() {
        path.removeAll()
    }
}
