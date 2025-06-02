//
//  MenuAction.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
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
                Icons.a
            case .report:
                Icons.xBold
        }
    }

    var color: Color {
        switch self {
            case .save:
                Colors.whitePrimary
            case .share:
                Colors.whitePrimary
            case .translate:
                Colors.whitePrimary
            case .report:
                Colors.redAccent
        }
    }
}
