//
//  QuickLook.swift
//  Environment
//
//  Created by Артем Васин on 10.01.25.
//

import SwiftUI
import Models

public final class QuickLook: ObservableObject {
    @Published public var selectedMediaAttachment: MediaData?
    public var mediaAttachments: [MediaData?] = []
    
    public static let shared = QuickLook()
    
    private init() {}
    
    public func prepareFor(selectedMediaAttachment: MediaData?, mediaAttachments: [MediaData?]) {
        self.selectedMediaAttachment = selectedMediaAttachment
        self.mediaAttachments = mediaAttachments
    }
}
