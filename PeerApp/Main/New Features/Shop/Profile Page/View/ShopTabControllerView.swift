//
//  ShopTabControllerView.swift
//  PeerApp
//
//  Created by Artem Vasin on 05.01.26.
//

import SwiftUI
import DesignSystem

enum ShopItemsDisplayType: CaseIterable {
    case list
    case grid

    var pageIcon: Image {
        switch self {
            case .list:
                IconsNew.displayTypeList
            case .grid:
                IconsNew.displayTypeGrid
        }
    }
}

struct ShopTabControllerView: View {
    @Binding var type: ShopItemsDisplayType

    @Namespace private var tabsNamespace

    init(type: Binding<ShopItemsDisplayType>) {
        self._type = type
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(ShopItemsDisplayType.allCases, id: \.self) { page in
                ZStack(alignment: .bottom) {
                    Button {
                        type = page
                    } label: {
                        page.pageIcon
                            .iconSize(height: 14)
                            .foregroundStyle(type == page ? Colors.whitePrimary : Colors.whiteSecondary)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }

                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.5)

                    if type == page {
                        Capsule()
                            .frame(height: 1)
                            .matchedGeometryEffect(id: "ShopTab", in: tabsNamespace)
                    }
                }
                .foregroundStyle(Colors.whitePrimary)
                .animation(.default, value: type)
            }
        }
    }
}
