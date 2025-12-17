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
                    .padding(.bottom, ButtonSize.large.height + 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .overlay(alignment: .bottom) {
                let btnConfig = StateButtonConfig(buttonSize: .small, buttonType: .secondary, title: "Continue")

                StateButton(config: btnConfig, action: {}) //
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0), location: 0.00),
                                Gradient.Stop(color: Color(red: 0.15, green: 0.15, blue: 0.15), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                )
                    .ignoresSafeArea(.keyboard)
            }
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
