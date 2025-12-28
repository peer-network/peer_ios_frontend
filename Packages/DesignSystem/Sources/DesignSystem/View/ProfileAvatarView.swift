//
//  ProfileAvatarView.swift
//  DesignSystem
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import NukeUI
import Nuke

public struct ProfileAvatarView: View {
    public let url: URL?
    public let name: String?
    public let config: FrameConfig
    public let ignoreCache: Bool

    public init(url: URL? = nil, name: String? = nil, config: FrameConfig, ignoreCache: Bool) {
        self.url = url
        self.name = name
        self.config = config
        self.ignoreCache = ignoreCache
    }
    
    public var body: some View {
        if let url {
            AvatarImage(url: url, name: name, config: config, ignoreCache: ignoreCache)
        } else {
            AvatarPlaceHolder(name: name, config: config)
        }
    }
    
    public struct FrameConfig: Equatable {
        let size: CGSize
        var width: CGFloat { size.width }
        var height: CGFloat { size.height }
        let cornerRadius: CGFloat
        
        init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
            size = CGSize(width: width, height: height)
            self.cornerRadius = cornerRadius
        }
        
        public static let post = FrameConfig(width: 40, height: 40, cornerRadius: 91)
        public static let rowUser = FrameConfig(width: 40, height: 40, cornerRadius: 91)
        public static let audioPlayer = FrameConfig(width: 35, height: 35, cornerRadius: 91)
        public static let profile = FrameConfig(width: 68, height: 68, cornerRadius: 91)
        public static let comment = FrameConfig(width: 50, height: 50, cornerRadius: 91)
        public static let settings = FrameConfig(width: 50, height: 50, cornerRadius: 91)
        public static let transactionHistory = FrameConfig(width: 55, height: 55, cornerRadius: 91)
    }
    
    private struct AvatarImage: View {
        @Environment(\.redactionReasons) private var reasons
        
        let url: URL
        let name: String?
        let config: FrameConfig
        let ignoreCache: Bool

        var body: some View {
            if reasons == .placeholder {
                AvatarPlaceHolder(name: name, config: config)
            } else {
                let request = ignoreCache ?
                ImageRequest(
                    url: url,
                    processors: [.resize(size: config.size)],
                    options: [.reloadIgnoringCachedData]
                ) :
                ImageRequest(
                    url: url,
                    processors: [.resize(size: config.size)],
                    options: [.reloadIgnoringCachedData]
                )

                LazyImage(request: request) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: config.width, height: config.height)
                            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
                    } else {
                        AvatarPlaceHolder(name: name, config: config)
                    }
                }
            }
        }
    }
    
    private struct AvatarPlaceHolder: View {
        @Environment(\.redactionReasons) private var redactionReasons
        
        let name: String?
        let config: FrameConfig
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .fill(.gray)
                    .frame(width: config.width, height: config.height)
                
                if !redactionReasons.contains(.placeholder), let letter = name?.first {
                    Text("\(letter)".capitalized)
                        .font(.system(size: config.height / 2))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    VStack {
        ProfileAvatarView(url: URL(string: ""), name: "Artem", config: .profile, ignoreCache: true)

        ProfileAvatarView(url: URL(string: "https://www.zoobasel.ch/uploads/images/news/fotos/shetlandpony_cacahuete_Z6B5123.jpg"), name: "Daniel", config: .profile, ignoreCache: true)
    }
}
