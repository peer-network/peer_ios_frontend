//
//  ScreenTrackable.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

public protocol ScreenTrackable {
    var screenName: String { get }
    var screenClass: String { get }
    var shouldSuspendWhenBackgrounded: Bool { get }
}
