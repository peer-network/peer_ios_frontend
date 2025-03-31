//
//  AvatarView.swift
//  DesignSystem
//
//  Created by Артем Васин on 23.12.24.
//

import SwiftUI
import NukeUI

public struct AvatarView: View {
    public let avatar: URL?
    public let name: String?
    public let config: FrameConfig
    
    public init(_ avatar: URL? = nil, config: FrameConfig = .post, name: String?) {
        self.avatar = avatar
        self.config = config
        self.name = name
    }
    
    public var body: some View {
        if let avatar {
            AvatarImage(avatar, config: adaptiveConfig, name: name)
                .frame(width: config.width, height: config.height)
        } else {
            AvatarPlaceHolder(config: adaptiveConfig, name: name)
        }
    }
    
    private var adaptiveConfig: FrameConfig {
        let cornerRadius: CGFloat =
        if config == .badge {
            config.width / 2
        } else {
            config.cornerRadius
        }
        return FrameConfig(width: config.width, height: config.height, cornerRadius: cornerRadius)
    }
    
    public struct FrameConfig: Equatable {
        public let size: CGSize
        public var width: CGFloat { size.width }
        public var height: CGFloat { size.height }
        let cornerRadius: CGFloat
        
        init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 4) {
            size = CGSize(width: width, height: height)
            self.cornerRadius = cornerRadius
        }
        
        public static let account = FrameConfig(width: 80, height: 80)
        public static let post = FrameConfig(width: 40, height: 40)
        public static let embed = FrameConfig(width: 34, height: 34)
        public static let badge = FrameConfig(width: 28, height: 28, cornerRadius: 14)
        public static let badgeRounded = FrameConfig(width: 28, height: 28)
        public static let list = FrameConfig(width: 20, height: 20, cornerRadius: 10)
        public static let boost = FrameConfig(width: 12, height: 12, cornerRadius: 6)
        public static let profile = FrameConfig(width: 68, height: 68, cornerRadius: 91)
    }
}

struct AvatarImage: View {
    @Environment(\.redactionReasons) private var reasons
    
    public let avatar: URL
    public let config: AvatarView.FrameConfig
    public let name: String?
    
    init(_ avatar: URL, config: AvatarView.FrameConfig, name: String?) {
        self.avatar = avatar
        self.config = config
        self.name = name
    }
    
    var body: some View {
        if reasons == .placeholder {
            AvatarPlaceHolder(config: config, name: name)
        } else {
            LazyImage(
                request: ImageRequest(url: avatar, processors: [.resize(size: config.size)])
            ) { state in
                if let image = state.image {
                    image
                        .resizable()
//                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: config.cornerRadius)
                                .stroke(.primary.opacity(0.25), lineWidth: 1)
                        )
                } else {
                    AvatarPlaceHolder(config: config, name: name)
                }
            }
            .onCompletion { result in
                print(result)
            }
        }
    }
}

struct AvatarPlaceHolder: View {
    @Environment(\.redactionReasons) private var redactionReasons
    
    let config: AvatarView.FrameConfig
    let name: String?
    
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
