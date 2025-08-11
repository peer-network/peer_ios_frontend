//
//  ShareToolbarItem.swift
//  MediaUI
//
//  Created by Артем Васин on 10.01.25.
//

import SwiftUI
import Models

struct ShareToolbarItem: ToolbarContent {
    let data: MediaData
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            MediaUIShareLink(data: data)
        }
    }
}
