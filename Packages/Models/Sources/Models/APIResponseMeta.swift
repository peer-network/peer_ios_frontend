//
//  APIResponseMeta.swift
//  Models
//
//  Created by Artem Vasin on 27.01.26.
//

import Foundation

public struct APIResponseMeta: Sendable, Hashable {
    public let status: String?
    public let responseCode: String?
    public let responseMessage: String?
    public let requestId: String?


    public init(
        status: String? = nil,
        responseCode: String? = nil,
        responseMessage: String? = nil,
        requestId: String? = nil
    ) {
        self.status = status
        self.responseCode = responseCode
        self.responseMessage = responseMessage
        self.requestId = requestId
    }


    public var isSuccess: Bool {
        guard
            let code = responseCode,
            let first = code.first,
            let digit = Int(String(first))
        else { return false }


        return digit == 1 || digit == 2
    }


    public var hasAnyInfo: Bool {
        status != nil || responseCode != nil || responseMessage != nil || requestId != nil
    }
}
