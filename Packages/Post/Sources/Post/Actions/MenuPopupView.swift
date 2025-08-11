//
//  MenuPopupView.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem

struct MorePopupView: View {
    var body: some View {
        PopupTransparentStyleView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(MoreActions.allCases, id: \.self) { action in
                    Button {
                        //
                    } label: {
                        HStack(spacing: 10) {
                            if action == .report {
                                action.icon
                                    .iconSize(height: 11)
                                    .padding(4)
                            } else {
                                action.icon
                                    .iconSize(height: 17)
                            }

                            Text(action.rawValue)
                                .font(.customFont(weight: .regular, style: .footnote))
                        }
                        .foregroundStyle(action.color)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Colors.textActive
            .ignoresSafeArea()

        MorePopupView()
    }
}
