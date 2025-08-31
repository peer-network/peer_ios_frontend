//
//  ImageState.swift
//  PostCreation
//
//  Created by Artem Vasin on 04.06.25.
//

import SwiftUI
import PhotosUI

struct ImageState {
    enum LoadingState {
        case loading
        case loaded(UIImage)
        case failed(Error)
    }

    let id: String
    var state: LoadingState
    var pickerItem: PhotosPickerItem?
}

enum PostImagesAspectRatio {
    case square
    case vertical

    var title: String {
        switch self {
            case .square: return "1:1 Square"
            case .vertical: return "4:5 Vertical"
        }
    }

    func imageFrameHeight(for screenWidth: CGFloat) -> CGFloat {
        switch self {
            case .square:
                return screenWidth - 60
            case .vertical:
                return (screenWidth - 60) * 5 / 4
        }
    }

    func imageFrameWidth(for screenWidth: CGFloat) -> CGFloat {
        switch self {
            case .square, .vertical:
                return screenWidth - 60
        }
    }
}
