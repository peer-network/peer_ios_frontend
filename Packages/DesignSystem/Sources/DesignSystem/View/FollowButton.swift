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
    public unowned var apiService: APIService!

    private let id: String
    let isFollowing: Bool
    @Published public private(set) var isFollowed: Bool

    public init(id: String, isFollowing: Bool, isFollowed: Bool) {
        self.id = id
        self.isFollowing = isFollowing
        self.isFollowed = isFollowed
    }

    public func toggleFollow() async {
        do {
            let result = await apiService.followUser(with: id)
            if case .failure(let error) = result {
                throw error
            }
            withAnimation {
                isFollowed.toggle()
            }
        } catch {
            //            isFollowed.toggle()
        }
    }
}

public struct FollowButton: View {
    @EnvironmentObject private var apiManager: APIServiceManager

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
                    Text("peer")
                        .bold()
                        .italic()
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
                    .foregroundStyle(Colors.whitePrimary)
                }
            }
            .font(.customFont(weight: .regular, size: .footnoteSmall))
            .padding(10)
            .frame(minWidth: 82)
            .background {
                if viewModel.isFollowing && viewModel.isFollowed {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Gradients.activeButtonBlue)
                } else if viewModel.isFollowed {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Colors.hashtag)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(lineWidth: 1)
                        .foregroundStyle(Colors.whitePrimary)
                }
            }
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
    }
}

public struct FollowButton2: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel: FollowButtonViewModel

    var buttonSize = ButtonSize.small

    var buttonType: ButtonType {
        if viewModel.isFollowing && viewModel.isFollowed {
            return .primary
        } else if viewModel.isFollowed {
            return .secondary
        } else {
            return .teritary
        }
    }

    var buttonText: String {
        if viewModel.isFollowing && viewModel.isFollowed {
            return "peer"
        } else if viewModel.isFollowed {
            return "Following"
        } else {
            return "Follow"
        }
    }

    public init(viewModel: FollowButtonViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        let config = StateButtonConfig(buttonSize: buttonSize, buttonType: buttonType, title: buttonText)

        AsyncStateButton(config: config) {
            await viewModel.toggleFollow()
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
    }
}

#Preview {
    VStack {
        let vm = FollowButtonViewModel(id: "", isFollowing: false, isFollowed: false)
        FollowButton(viewModel: vm)
            .environmentObject(APIServiceManager(.mock))
    }
    .background {
        Color.orange
    }
}
