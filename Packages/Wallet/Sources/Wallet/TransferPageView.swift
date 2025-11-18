//
//  TransferPageView.swift
//  Wallet
//
//  Created by Artem Vasin on 05.05.25.
//

import SwiftUI
import Models
import Environment
import DesignSystem
import Analytics

public struct TransferPageView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager
    
    @StateObject private var viewModel: TransferPageViewModel

    public init(recipient: RowUser, amount: Int) {
        _viewModel = .init(wrappedValue: .init(recipient: recipient, amount: amount))
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Wallet")
        } content: {
            ScrollView {
                VStack(spacing: 20) {
                    switch viewModel.screenState {
                        case .confirmation:
                            Group {
                                transferHeader
                                    .padding(.horizontal, 10)
                                    .padding(.top, 10)
                                TransferConfirmationView()
                            }
                            .transition(.blurReplace)
                        case .approving:
                            TransferApprovingView()
                                .transition(.blurReplace)
                        case .done:
                            TransferDoneView()
                                .transition(.blurReplace)
                        case .failed(let error):
                            TransferFailedView(error: error)
                                .transition(.blurReplace)
                    }
                }
                .environmentObject(viewModel)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
        }
        .background(Colors.textActive)
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
//        .trackScreen(AppScreen.wallet) TODO: TransferScreen
    }

    private var transferHeader: some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .frame(height: 40)
                .overlay {
                    Icons.arrowDownNormal
                        .iconSize(height: 14.5)
                        .foregroundStyle(Colors.blackDark)
                        .rotationEffect(.degrees(225))
                }

            Text("Transfer")
                .font(.customFont(weight: .regular, style: .footnote))

            Spacer()

            Button {
                router.path.removeLast()
            } label: {
                Icons.x
                    .iconSize(height: 12)
                    .contentShape(Rectangle())
            }
        }
        .foregroundStyle(Colors.whitePrimary)
    }
}

struct TransferConfirmationView: View {
    @EnvironmentObject private var viewModel: TransferPageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Checkout")
                .font(.customFont(weight: .regular, style: .footnote))
                .foregroundStyle(Colors.whitePrimary)
                .padding(.leading, 10)

            RowUserView(user: viewModel.recipient)

            HStack(spacing: 10) {
                Text(viewModel.amountWithFee, format: .number)
                    .font(.customFont(weight: .bold, style: .headline))
                    .foregroundStyle(Colors.whitePrimary)

                Icons.logoCircleWhite
                    .iconSize(height: 23)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Colors.blackDark)
            }

            Text("Including \(Text(viewModel.feeAmount, format: .number)) fee")
                .font(.customFont(weight: .regular, style: .footnote))
                .foregroundStyle(Colors.whiteSecondary)
                .padding(.leading, 10)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.completeTransfer()
                }
            } label: {
                HStack(spacing: 10) {
                    Text("Send")
                        .font(.customFont(weight: .regular, style: .footnote))

                    Icons.arrowDownNormal
                        .iconSize(height: 14.5)
                        .rotationEffect(.degrees(270))
                }
                .foregroundStyle(Colors.blackDark)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(Colors.whitePrimary)
                }
            }

        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}

struct TransferApprovingView: View {
    var body: some View {
        VStack(spacing: 0) {
            LottieView(animation: .loading)
                .frame(height: 47 * 3)

            let text1 = Text("Approving your transaction. ").bold()
            let text2 = Text("May take some time...")

            (text1 + text2)
                .foregroundStyle(Colors.whitePrimary)
                .font(.customFont(weight: .regular, style: .footnote))
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}

struct TransferDoneView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var viewModel: TransferPageViewModel

    var body: some View {
        VStack(spacing: 0) {
            Button {
                router.path.removeLast()
            } label: {
                Icons.x
                    .iconSize(height: 12)
                    .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            Circle()
                .strokeBorder(lineWidth: 2)
                .frame(height: 57)
                .overlay {
                    Icons.checkmark
                        .iconSize(height: 27)
                }
                .padding(.bottom, 20)

            HStack(spacing: 10) {
                Text("-\(Text(viewModel.amountWithFee, format: .number))")
                    .font(.customFont(weight: .bold, style: .title1))

                Icons.logoCircleWhite
                    .iconSize(height: 23)
            }

            HStack {
                Text("Where to")
                    .foregroundStyle(Colors.whiteSecondary)
                    .font(.customFont(weight: .regular, style: .footnote))

                Spacer()

                RowUserView(user: viewModel.recipient)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
        }
        .foregroundStyle(Colors.whitePrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}

struct TransferFailedView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var viewModel: TransferPageViewModel

    let error: APIError

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 0) {
                Button {
                    router.path.removeLast()
                } label: {
                    Icons.x
                        .iconSize(height: 12)
                        .contentShape(Rectangle())
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                Circle()
                    .strokeBorder(lineWidth: 2)
                    .frame(height: 57)
                    .overlay {
                        Icons.x
                            .iconSize(height: 27)
                    }
                    .padding(.bottom, 20)

                VStack(spacing: 10) {
                    Text("Transfer failed")
                        .font(.customFont(weight: .bold, style: .body))

                    Text(error.userFriendlyMessage)
                        .font(.customFont(weight: .regular, style: .footnote))
                }
                .frame(maxWidth: .infinity)
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(Colors.redAccent)
            .padding(.horizontal, 10)
            .padding(.vertical, 20)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Colors.inactiveDark)
            }

            HStack(spacing: 10) {
                Button {
                    router.emptyPath()
                } label: {
                    Text("Back to Wallet")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay {
                            RoundedRectangle(cornerRadius: 25)
                                .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                        }
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.completeTransfer()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text("Try again")
                            .font(.customFont(weight: .regular, style: .footnote))

                        Icons.arrowCounterClockwise
                            .iconSize(height: 18)
                    }
                    .foregroundStyle(Colors.blackDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundStyle(Colors.whitePrimary)
                    }
                }
            }
            .foregroundStyle(Colors.whitePrimary)
            .font(.customFont(weight: .regular, size: .body))
        }
    }
}
