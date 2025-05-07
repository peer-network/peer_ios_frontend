//
//  WithdrawalView.swift
//  Wallet
//
//  Created by Artem Vasin on 02.05.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

struct WithdrawalView: View {
    @StateObject private var viewModel = TransferViewModel()

    var body: some View {
        VStack(spacing: 20) {
            switch viewModel.screenState {
                case .main:
                    TransferTileView()
                        .transition(.blurReplace)
                case .inputAmount:
                    Group {
                        transferHeader
                        if let recipient = viewModel.recipient {
                            RowUserView(user: recipient)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        TransferAmountInputView()

                        Text("A fee of 4% applies")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.customFont(weight: .regular, style: .footnote))
                            .foregroundStyle(Colors.whiteSecondary)
                            .padding(.leading, 10)
                            .padding(.bottom, 20)
                    }
            }
        }
        .environmentObject(viewModel)
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.resetProcess()
                }
            } label: {
                Icons.x
                    .iconSize(height: 12)
                    .contentShape(Rectangle())
            }
        }
        .foregroundStyle(Colors.whitePrimary)
    }
}

struct TransferTileView: View {
    @EnvironmentObject private var viewModel: TransferViewModel

    @State private var isExpanded = false
    @State private var showRecipientPicker: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Circle()
                        .frame(height: 40)
                        .overlay {
                            Icons.arrowDownNormal
                                .iconSize(height: 14.5)
                                .foregroundStyle(Colors.whitePrimary)
                                .rotationEffect(.degrees(225))
                        }

                    Text("Transfer")
                        .font(.customFont(weight: .regular, style: .footnote))

                    Spacer()

                    Icons.arrowDown
                        .iconSize(height: 6)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }

            if isExpanded {
                chooseRecipientButton
            }
        }
        .foregroundStyle(Colors.blackDark)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(Colors.whitePrimary)
        }
        .sheet(isPresented: $showRecipientPicker) {
            RecipientPickerSheet { user in
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.setRecipient(user)
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(24)
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.large])
            .presentationContentInteraction(.resizes)
        }
    }

    private var chooseRecipientButton: some View {
        Button {
            showRecipientPicker = true
        } label: {
            HStack(spacing: 10) {
                Text("Choose recipient")
                    .font(.customFont(weight: .bold, style: .footnote))

                Icons.plus
                    .iconSize(height: 11)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 40)
            .background {
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(lineWidth: 1)
            }
        }
        .foregroundStyle(Colors.blackDark)
    }
}

struct TransferAmountInputView: View {
    @EnvironmentObject private var router: Router

    @EnvironmentObject private var walletVM: WalletViewModel
    @EnvironmentObject private var viewModel: TransferViewModel

    @State private var amount: Int?

    @FocusState private var isInputActive: Bool

    var body: some View {
        TextField(value: $amount, format: .number.grouping(.automatic)) {
            Text("Amount to send")
                .font(.customFont(weight: .regular, style: .footnote))
                .foregroundStyle(Colors.whiteSecondary)
        }
        .focused($isInputActive)
        .submitLabel(.done)
        .lineLimit(1)
        .keyboardType(.numberPad)
        .padding(.trailing, 50)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 60)
        .padding(.leading, 20)
        .overlay(alignment: .trailing) {
            if let amount, amount > 0 {
                Button {
                    guard let recipient = viewModel.recipient else { return }
                    router.navigate(to: .transfer(recipient: recipient, amount: amount))
                } label: {
                    Circle()
                        .frame(height: 40)
                        .overlay {
                            Icons.arrowDownNormal
                                .iconSize(height: 14.5)
                                .foregroundStyle(Colors.blackDark)
                                .rotationEffect(.degrees(270))
                        }
                }
                .padding(.trailing, 10)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Colors.inactiveDark)
        }
        .font(.customFont(weight: .bold, style: .headline))
        .foregroundStyle(Colors.whitePrimary)
        .onAppear {
            if amount != nil {
                viewModel.resetProcess()
            } else {
                isInputActive = true
            }
        }
        .onChange(of: amount) {
            guard
                let amount,
                let currentBalance = walletVM.balance?.amount
            else {
                return
            }

            if amount > Int(currentBalance) {
                self.amount = Int(currentBalance)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    isInputActive = false
                }
                .foregroundStyle(Colors.whitePrimary)
            }
        }
    }
}

#Preview {
    WithdrawalView()
}
