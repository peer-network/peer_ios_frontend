//
//  EnvironmentValues.swift
//  Environment
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var isInCaptureMode: Bool = false
    
    // actually used in prod
    @Entry var isBackgroundWhite: Bool = true
    @Entry var selectedTabScrollToTop: Int = -1
    @Entry var selectedTabEmptyPath: Int = -1
}
