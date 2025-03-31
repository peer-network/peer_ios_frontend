//
//  MorePopupView.swift
//  FeedNew
//
//  Created by Artem Vasin on 19.03.25.
//

import SwiftUI
import DesignSystem

enum MoreActions: String, CaseIterable {
    case save = "Save"
    case share = "Share"
    case translate = "Translate"
    case report = "Report"

    var icon: Image {
        switch self {
            case .save:
                Icons.bookmark
            case .share:
                Icons.arrowShare
            case .translate:
                Icons.magnifyingglassFill
            case .report:
                Icons.xBold
        }
    }

    var color: Color {
        switch self {
            case .save:
                Color.white
            case .share:
                Color.white
            case .translate:
                Color.white
            case .report:
                Color.redAccent
        }
    }
}

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
    MorePopupView()
}
