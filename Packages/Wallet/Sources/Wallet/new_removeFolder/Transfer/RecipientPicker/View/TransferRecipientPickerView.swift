//
//  TransferRecipientPickerView.swift
//  Wallet
//
//  Created by Artem Vasin on 17.12.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

struct TransferRecipientPickerView<Value: Hashable>: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @Binding var focusState: Value?
    let focusEquals: Value?

    let onSubmit: (RowUser?) -> Void

    @StateObject private var viewModel = TransferRecipientViewModel()

    @State private var searchText: String = ""

    enum PickerState {
        case unknown
        case picked(RowUser)
    }

    @State private var pickerState: PickerState = .unknown

    var body: some View {
        Group {
            switch pickerState {
                case .unknown:
                    pickerView
                case .picked(let user):
                    pickedView(user)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private var pickerView: some View {
        VStack(spacing: 10) {
            Text("Recipient username")
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            DataInputTextField(
                backgroundColor: Colors.blackDark,
                trailingIcon: Icons.magnifyingglass,
                text: $searchText,
                placeholder: "Search user...",
                maxLength: 100,
                focusState: $focusState,
                focusEquals: focusEquals,
                returnKeyType: .search,
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusState = nil
                }
            )

            ScrollView {
                Group {
                    switch viewModel.state {
                        case .loading:
                            // Optional: show placeholders instead of EmptyView so it feels smooth
                            EmptyView()
                                .transition(.opacity)

                        case .display(let users, let hasMore):
                            let displayUsers = users.filter { $0.id != AccountManager.shared.user?.id }

                            LazyVStack(spacing: 10) {
                                ForEach(displayUsers) { user in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            onSubmit(user)
                                            pickerState = .picked(user)
                                            searchText = ""
                                            viewModel.clearResults()
                                        }
                                    } label: {
                                        HStack(spacing: 0) {
                                            Text("@\(user.username)")
                                                .appFont(.smallLabelBoldItalic)
                                                .foregroundStyle(Colors.whitePrimary)
                                                .padding(.trailing, 2)

                                            Text("#\(String(user.slug))")
                                                .appFont(.smallLabelRegular)

                                            Spacer(minLength: 10)

                                            Icons.arrowDown
                                                .iconSize(height: 8.73)
                                                .rotationEffect(.degrees(270))
                                        }
                                        .lineLimit(1)
                                        .foregroundStyle(Colors.whiteSecondary)
                                        .frame(height: 50)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 10)
                                        .background {
                                            RoundedRectangle(cornerRadius: 30)
                                                .foregroundStyle(Colors.blackDark)
                                        }
                                        .contentShape(.rect)
                                    }
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                }

                                if case .hasMore = hasMore {
                                    NextPageView {
                                        viewModel.fetchContent(username: searchText, reset: false)
                                    }
                                    .padding(.horizontal, 20)
                                    .transition(.opacity)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))

                        case .error(let error):
                            ErrorView(title: "Error", description: error.userFriendlyDescription) {
                                viewModel.fetchContent(username: searchText, reset: true)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: viewModel.stateVersion)
            }

            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.visible)
            .scrollTargetLayout()
        }
        .onChange(of: searchText) {
            let username = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !username.isEmpty && username.count > 2 {
                viewModel.fetchContent(username: username, reset: true)
            }
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
    }

    private func pickedView(_ user: RowUser) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Sending to")
                    .appFont(.bodyRegular)
                    .foregroundStyle(Colors.whitePrimary)

                HStack(spacing: 2) {
                    Text("@\(user.username)")
                        .appFont(.bodyBoldItalic)
                        .foregroundStyle(Colors.whitePrimary)
                    Text("#\(String(user.slug))")
                        .appFont(.bodyRegular)
                        .foregroundStyle(Colors.whiteSecondary)
                }
                .lineLimit(1)
            }

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            Button {
                withAnimation(.easeInOut) {
                    onSubmit(nil)
                    pickerState = .unknown
                    focusState = focusEquals
                }
            } label: {
                Circle()
                    .foregroundStyle(Colors.blackDark)
                    .frame(height: 35)
                    .overlay {
                        Icons.pen
                            .iconSize(height: 15)
                            .foregroundStyle(Colors.whitePrimary)
                    }
            }
        }
    }

    @ViewBuilder
    private func row(_ user: RowUser) -> some View {
        HStack(spacing: 0) {
            Text("@\(user.username)")
                .appFont(.smallLabelBoldItalic)
                .foregroundStyle(Colors.whitePrimary)
                .padding(.trailing, 2)

            Text("#\(String(user.slug))")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whiteSecondary)

            Spacer(minLength: 10)

            Icons.arrowDown
                .iconSize(height: 8.73)
                .rotationEffect(.degrees(270))
                .foregroundStyle(Colors.whiteSecondary)
        }
        .lineLimit(1)
        .frame(height: 50)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(Colors.blackDark)
        }
        .contentShape(.rect)
    }

}
