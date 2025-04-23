//
//  AuthEvent.swift
//  Analytics
//
//  Created by Artem Vasin on 23.04.25.
//

public enum AuthEvent: AnalyticsEvent {
    case login
    case signUp
    case logout

    public var eventType: String {
        switch self {
            case .login:
                return "login"
            case .signUp:
                return "sign_up"
            case .logout:
                return "logout"
        }
    }

    public var eventParameters: [String : Any]? {
        switch self {
            case .login:
                return nil
            case .signUp:
                return nil
            case .logout:
                return nil
        }
    }
}
