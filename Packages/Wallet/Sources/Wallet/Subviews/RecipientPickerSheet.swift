//
//  RecipientPickerSheet.swift
//  Wallet
//
//  Created by Artem Vasin on 02.05.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

struct RecipientPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = RecipientPickerViewModel(apiService: APIServiceManager().apiService)

    let completion: (RowUser) -> Void

    @frozen
    public enum Field {
        case search
    }

    @FocusState private var focusedField: Field?
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Capsule()
                .frame(width: 44.5, height: 1)
                .foregroundStyle(Colors.whitePrimary)

            Text("Choose recipient")
                .font(.customFont(weight: .regular, size: .body))
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            searchTextFieldView

            ScrollView {
                switch viewModel.state {
                    case .loading(let users):
                        ForEach(users) { user in
                            RowProfileSearchView(user: user)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .allowsHitTesting(false)
                                .skeleton(isRedacted: true)
                        }
                    case .display(let users, let hasMore):
                        LazyVStack(spacing: 20) {
                            ForEach(users) { user in
                                Button {
                                    dismiss()
                                    Task { @MainActor in
                                        try? await Task.sleep(for: .seconds(0.5))
                                        completion(user)
                                    }
                                } label: {
                                    RowProfileSearchView(user: user)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                }
                            }

                            switch hasMore {
                                case .hasMore:
                                    NextPageView {
                                        viewModel.fetchContent(username: searchText, reset: false)
                                    }
                                    .padding(.horizontal, 20)
                                case .none:
                                    EmptyView()
                            }
                        }
                    case .error(let error):
                        ErrorView(title: "Error", description: error.localizedDescription) {
                            viewModel.fetchContent(username: searchText, reset: true)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(10)
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            focusedField = .search
        }
        .onChange(of: searchText) {
            let username = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !username.isEmpty && username.count > 2 {
                viewModel.fetchContent(username: username, reset: true)
            }
        }
    }

    private var searchTextFieldView: some View {
        HStack(spacing: 0) {
            Text("@")
                .font(.customFont(weight: .boldItalic, style: .footnote))
                .foregroundColor(.white.opacity(0.5))

            TextField(text: $searchText) {
                Text("")
            }
            .focused($focusedField, equals: .search)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .lineLimit(1)
            .font(.customFont(weight: .boldItalic, style: .footnote))
            .foregroundColor(.white)

            Spacer()
                .frame(width: 10)

            Button {
                withAnimation {
                    searchText = ""
                    viewModel.clearResults()
                }
            } label: {
                Icons.arrowsBackRounded
                    .iconSize(height: 21)
                    .foregroundStyle(Colors.whitePrimary)
            }
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .frame(height: 50)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.textActive)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Colors.whitePrimary, lineWidth: 1)
        }
    }
}

struct RowProfileSearchView: View {
    let user: RowUser

    var body: some View {
        HStack(spacing: 0) {
            ProfileAvatarView(url: user.imageURL, name: user.username, config: .rowUser)
                .padding(.trailing, 10)

            Text(user.username)
                .font(.customFont(weight: .boldItalic, style: .callout))
                .padding(.trailing, 5)

            Text("#\(String(user.slug))")
                .opacity(0.5)
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .foregroundStyle(Colors.whitePrimary)
    }
}
