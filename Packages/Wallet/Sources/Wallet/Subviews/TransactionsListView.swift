//
//  TransactionsListView.swift
//  Wallet
//
//  Created by Artem Vasin on 24.11.25.
//

import SwiftUI
import DesignSystem

struct TransactionsListView: View {
    @Binding var isHeaderAtTop: Bool
    let scrollProxy: ScrollViewProxy

    var body: some View {
        VStack(spacing: 0) {
            LazyVStack(spacing: 10, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(0..<100) { i in
                        Text("Example \(i)")
                            .font(.title)
                            .frame(width: 200, height: 200)
                            .background(Colors.passwordBarsGreen)
                    }
                } header: {
                    transactionHistoryHeaderView
                        .background(Colors.blackDark)
                        .overlay(
                            GeometryReader { geo in
                                Color.clear
                                    .onChange(of: geo.frame(in: .global).minY) { newValue in
                                        if newValue < 107 {
                                            isHeaderAtTop = true
                                        } else {
                                            isHeaderAtTop = false
                                        }
                                    }
                            }
                        )
                }
            }
        }
    }

    private var transactionHistoryHeaderView: some View {
        Button {
            if isHeaderAtTop {
                withAnimation {
                    scrollProxy.scrollTo(0, anchor: .top)
                }
            } else {
                withAnimation {
                    scrollProxy.scrollTo(1, anchor: .top)
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text("Transactions")
                    .appFont(.bodyBold)

                Spacer()
                    .frame(minWidth: 0)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                Icons.arrowDown
                    .iconSize(height: 8)
                    .rotationEffect(.degrees(isHeaderAtTop ? 180 : 0))
                    .animation(.easeInOut, value: isHeaderAtTop)
            }
            .foregroundStyle(Colors.whitePrimary)
            .padding(.vertical, 10)
            .contentShape(.rect)
        }
    }
}
