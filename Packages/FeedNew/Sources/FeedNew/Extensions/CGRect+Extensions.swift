//
//  CGRect+Extensions.swift
//  FeedNew
//
//  Created by Artem Vasin on 18.03.25.
//

import UIKit

extension CGRect {
    var intersectsVisibleArea: Bool {
        let screenHeight = UIScreen.main.bounds.height
        let visibleHeight = max(0, min(maxY, screenHeight) - max(minY, 0))
        let percentageVisible = visibleHeight / height
        return percentageVisible >= 0.7
    }
}
