//
//  ReferralPageView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 26.05.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models
import Analytics

public struct ReferralPageView: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel = ReferralViewModel()

    public init() {}
    
    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Settings")
        } content: {
            pageContent
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            Task {
                await viewModel.getMyReferralInfo()
            }
            viewModel.getMyReferredUsers(reset: true)
        }
        .trackScreen(AppScreen.referrals)
    }

    private var pageContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                infoTextView

                myReferringData

                referredUsersView
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20)
        }
        .refreshable {
            viewModel.getMyReferredUsers(reset: true)
        }
    }

    private var infoTextView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Referral program")
                .font(.customFont(weight: .regular, style: .title1))

            Text("Invite a friend and earn \(Text("1% of their earnings").bold()) every time they transfer or cash out \(Text("forever").bold()). The more you refer, the more you earn!")

            Text("Copy your referral link or code and share it with person. Make sure he entered it while registration.")
        }
        .font(.customFont(weight: .regular, style: .callout))
        .foregroundStyle(Colors.whitePrimary)
    }

    @ViewBuilder
    private var myReferringData: some View {
        switch viewModel.refInfoState {
            case .loading:
                inviteFriendsButton
                    .skeleton(isRedacted: true)
                    .allowsHitTesting(false)
            case .display:
                inviteFriendsButton
            case .error(let error):
                ErrorView(title: "Error", description: error.userFriendlyDescription) {
                    viewModel.getMyReferredUsers(reset: true)
                }
        }
    }

    private var inviteFriendsButton: some View {
        HStack(spacing: 10) {
            Button {
                HapticManager.shared.fireHaptic(.buttonPress)
                UIPasteboard.general.string = viewModel.myReferralInfo!.referralLink
                showPopup(
                    text: "Copied to clipboard"
                )
            } label: {
                HStack(spacing: 10) {
                    Text("Copy link")
                        .font(.customFont(weight: .bold, style: .callout))

                    Icons.copy
                        .iconSize(height: 20)
                        .foregroundStyle(Colors.whiteSecondary)
                }
                .foregroundStyle(Colors.whitePrimary)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Colors.inactiveDark)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }

            Button {
                HapticManager.shared.fireHaptic(.buttonPress)
                UIPasteboard.general.string = viewModel.myReferralInfo!.referralUuid
                showPopup(
                    text: "Copied to clipboard"
                )
            } label: {
                HStack(spacing: 10) {
                    Text("Copy code")
                        .font(.customFont(weight: .bold, style: .callout))
                        .multilineTextAlignment(.leading)

                    Icons.copy
                        .iconSize(height: 20)
                        .foregroundStyle(Colors.whiteSecondary)
                }
                .foregroundStyle(Colors.whitePrimary)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Colors.inactiveDark)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
    }

    private var referredUsersView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Referred people")
                .font(.customFont(weight: .regular, style: .title1))

            switch viewModel.refUsersState {
                case .loading:
                    referredUsersList(users: RowUser.placeholders(count: 5))
                        .skeleton(isRedacted: true)
                        .allowsHitTesting(false)
                case .display:
                    referredUsersList(users: viewModel.referredUsers)
                case .error(let error):
                    ErrorView(title: "Error", description: error.userFriendlyDescription) {
                        viewModel.getMyReferredUsers(reset: true)
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .foregroundStyle(Colors.whitePrimary)
    }

    @ViewBuilder
    private func referredUsersList(users: [RowUser]) -> some View {
        if users.isEmpty {
            Text("You haven't referred anyone yet.")
                .font(.customFont(weight: .regular, style: .callout))
        } else {
            LazyVStack(spacing: 20) {
                ForEach(users) { user in
                    RowProfileView(user: user)
                }

                if viewModel.hasMoreReferredUsers {
                    NextPageView {
                        viewModel.getMyReferredUsers(reset: false)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
