//
//  VideoState.swift
//  PostCreation
//
//  Created by Artem Vasin on 04.06.25.
//

import SwiftUI

struct VideoState {
    enum LoadingState {
        case loading
        case loaded(thumbnail: Image, videoURL: URL, duration: Double?)
    }

    let id: String
    var state: LoadingState
}
