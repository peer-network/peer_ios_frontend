//
//  FollowButton.swift
//  DesignSystem
//
//  Created by Артем Васин on 31.01.25.
//

import SwiftUI
import Environment
import Networking
import GQLOperationsUser

@MainActor
public final class FollowButtonViewModel: ObservableObject {
    private let id: String
    let isFollowing: Bool
    @Published public private(set) var isFollowed: Bool

    public init(id: String, isFollowing: Bool, isFollowed: Bool) {
        self.id = id
        self.isFollowing = isFollowing
        self.isFollowed = isFollowed
    }

    public func toggleFollow() async {
        withAnimation {
            isFollowed.toggle()
        }

        do {
            let result = try await GQLClient.shared.mutate(mutation: FollowUserMutation(userid: id))


            guard result.userFollow.status == "success" else {
                throw GQLError.missingData
            }
        } catch {
            isFollowed.toggle()
        }
    }
}

public struct FollowButton: View {
    @Environment(\.isBackgroundWhite) private var isBackgroundWhite

    @StateObject private var viewModel: FollowButtonViewModel
    
    public init(id: String, isFollowing: Bool, isFollowed: Bool) {
        _viewModel = .init(wrappedValue: .init(id: id, isFollowing: isFollowing, isFollowed: isFollowed))
    }

    public var body: some View {
        Button {
            Task {
                await viewModel.toggleFollow()
            }
        } label: {
            Group {
                if viewModel.isFollowing && viewModel.isFollowed {
                    Text("Peer")
                        .foregroundStyle(Colors.whitePrimary)
                } else if viewModel.isFollowed {
                    Text("Following")
                        .foregroundStyle(Colors.whitePrimary)
                } else {
                    HStack(alignment: .center, spacing: 10) {
                        Text("Follow")

                        Icons.plus
                            .iconSize(height: 12)
                    }
                    .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
                }
            }
            .font(.customFont(weight: .regular, size: .footnoteSmall))
            .padding(10)
            .frame(minWidth: 82)
            .background {
                if viewModel.isFollowing && viewModel.isFollowed {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Gradients.activeButtonBlue)
                        .shadow(color: .black.opacity(0.5), radius: 25, x: 0, y: 4)
                } else if viewModel.isFollowed {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Colors.hashtag)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(lineWidth: 1)
                        .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
                }
            }
        }
    }
}

#Preview {
    VStack {
        FollowButton(id: "", isFollowing: false, isFollowed: false)
            .environment(\.isBackgroundWhite, false)
        FollowButton(id: "", isFollowing: false, isFollowed: false)
            .environment(\.isBackgroundWhite, true)
        FollowButton(id: "", isFollowing: false, isFollowed: true)
            .environment(\.isBackgroundWhite, false)
        FollowButton(id: "", isFollowing: true, isFollowed: true)
            .environment(\.isBackgroundWhite, false)
    }
    .background {
        Color.orange
    }
}
