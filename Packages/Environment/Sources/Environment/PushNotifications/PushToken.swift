//
//  PushToken.swift
//  Environment
//
//  Created by Артем Васин on 20.12.24.
//

import Foundation

struct PushToken {
    private let encoder = JSONEncoder()
    
    let token: String
    let debug: Bool
    let language: String
    
    init(token: Data) {
        self.token = token.reduce("") { $0 + String(format: "%02x", $1) }
        language = Locale.preferredLanguages[0]
#if DEBUG
        encoder.outputFormatting = .prettyPrinted
        debug = true
        print(String(describing: self))
#else
        debug = false
#endif
    }
    
    func encoded() -> Data {
        try! encoder.encode(self)
    }
}

extension PushToken: Encodable {
    private enum CodingKeys: String, CodingKey {
        case token
        case debug
        case language
    }
}

extension PushToken: CustomStringConvertible {
    var description: String {
        String(data: encoded(), encoding: .utf8) ?? "Invalid token"
    }
}
