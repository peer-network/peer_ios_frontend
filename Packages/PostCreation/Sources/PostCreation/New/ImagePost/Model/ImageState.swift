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
