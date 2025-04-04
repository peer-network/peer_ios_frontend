//
//  FollowButton.swift
//  DesignSystem
//
//  Created by Артем Васин on 31.01.25.
//

import SwiftUI
import Environment
import Models

@MainActor
public final class FollowButtonViewModel: ObservableObject {
    private let id: String
    let isFollowing: Bool
    @Published public private(set) var isFollowed: Bool
    
    private let apiWrapper: any APIServiceWrapper

    public init(id: String, isFollowing: Bool, isFollowed: Bool, apiWrapper: any APIServiceWrapper) {
        self.id = id
        self.isFollowing = isFollowing
        self.isFollowed = isFollowed
        self.apiWrapper = apiWrapper
    }

    public func toggleFollow() async {
        withAnimation {
            isFollowed.toggle()
        }

        do {
            let result = await apiWrapper.apiService.followUser(with: id)
            if case .failure(let error) = result {
                throw error
            }
        } catch {
            isFollowed.toggle()
        }
    }
}

public struct FollowButton: View {
    @Environment(\.isBackgroundWhite) private var isBackgroundWhite

    @StateObject private var viewModel: FollowButtonViewModel
    
    public init(viewModel: FollowButtonViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                        .foregroundStyle(Color.white)
                } else if viewModel.isFollowed {
                    Text("Following")
                        .foregroundStyle(Color.white)
                } else {
                    HStack(alignment: .center, spacing: 10) {
                        Text("Follow")

                        Icons.plus
                            .iconSize(height: 12)
                    }
                    .foregroundStyle(isBackgroundWhite ? Color.backgroundDark : Color.white)
                }
            }
            .font(.customFont(weight: .regular, size: .footnoteSmall))
            .padding(10)
            .frame(minWidth: 82)
            .background {
                if viewModel.isFollowing && viewModel.isFollowed {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.47, green: 0.69, blue: 1), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0, green: 0.41, blue: 1), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0, y: 0.5),
                                endPoint: UnitPoint(x: 1, y: 0.5)
                            )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 25, x: 0, y: 4)
                } else if viewModel.isFollowed {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color.hashtag)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(lineWidth: 1)
                        .foregroundStyle(isBackgroundWhite ? Color.backgroundDark : Color.white)
                }
            }
        }
    }
}

#Preview {
    VStack {
        let vm = FollowButtonViewModel(id: "", isFollowing: false, isFollowed: false, apiWrapper: APIManagerStub())
        FollowButton(viewModel: vm)
            .environment(\.isBackgroundWhite, false)
    }
    .background {
        Color.orange
    }
}
