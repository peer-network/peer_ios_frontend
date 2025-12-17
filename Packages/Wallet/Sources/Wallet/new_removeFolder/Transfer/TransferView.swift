//
//  TransferView.swift
//  Wallet
//
//  Created by Artem Vasin on 17.12.25.
//

import SwiftUI
import DesignSystem

public struct TransferView: View {
    @frozen
    public enum FocusField {
        case recipientSearch
        case amount
        case message
    }

    @FocusState private var focusedField: FocusField?

    public init() {}
    
    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Transfer")
        } content: {
            ScrollView {
                content
                    .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onFirstAppear {
            focusedField = .recipientSearch
        }
    }

    private var content: some View {
        VStack(spacing: 10) {
//            GemsMainView()

            TransferRecipientPickerView(focusState: $focusedField, focusEquals: .recipientSearch) {
                //
            }

            TransferAmountView(focusState: $focusedField, focusEquals: .amount) {
                //
            }

            TransferMessageView(focusState: $focusedField, focusEquals: .message) {
                //
            }
        }
    }
}
