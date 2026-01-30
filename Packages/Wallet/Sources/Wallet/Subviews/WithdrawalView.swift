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

                        Text("A fee of \(viewModel.feePercents)% applies")
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

    @State private var showRecipientPicker: Bool = false

    var body: some View {
        Button {
            //
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

                VStack(alignment: .leading, spacing: 0) {
                    Text("Transfer")
                        .appFont(.bodyRegular)

                    Spacer()
                        .frame(minHeight: 0)
                        .frame(maxHeight: .infinity)
                        .layoutPriority(-1)

                    Text("To user")
                        .appFont(.smallLabelRegular)
                        .foregroundStyle(Colors.textSuggestions)
                }
                .frame(height: 40)

                Spacer()
                    .frame(minWidth: 0)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                Icons.arrowDownNormal
                    .iconSize(height: 15)
                    .rotationEffect(.degrees(-90))
            }
            .foregroundStyle(Colors.blackDark)
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundStyle(Colors.whitePrimary)
            }
            .contentShape(.rect)
        }

        .sheet(isPresented: $showRecipientPicker) {
            RecipientPickerSheet { user in
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.setRecipient(user)
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(24)
            .presentationBackground(Colors.blackDark)
            .presentationDetents([.large])
            .presentationContentInteraction(.resizes)
        }
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
                    router.navigate(to: RouterDestination.transfer(recipient: recipient, amount: amount))
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

            if amount > (currentBalance as NSDecimalNumber).intValue {
                self.amount = (currentBalance as NSDecimalNumber).intValue
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
