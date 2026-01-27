//
//  StatusSuccess.swift
//  Networking
//
//  Created by Alexander Savchenko on 02.04.25.
//

import ApolloAPI
import Models

extension SelectionSet {

    public var apiMeta: APIResponseMeta {
        Self._findMeta(in: __data, depth: 8) ?? APIResponseMeta(status: nil, responseCode: nil, responseMessage: nil, requestId: nil)
    }

    // Backwards-compatible API with your existing call sites
    public var getResponseCode: String? { apiMeta.responseCode }
    public var isResponseCodeSuccess: Bool { apiMeta.isSuccess }

    // MARK: - Private

    private static func _findMeta(in value: Any?, depth: Int) -> APIResponseMeta? {
        guard depth > 0, let value else { return nil }

        // Unwrap Optional<Any>
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional, let first = mirror.children.first?.value {
            return _findMeta(in: first, depth: depth - 1)
        }

        if let dict = value as? DataDict {
            let raw = dict._data

            // 1) NEW SHAPE: meta { status RequestId ResponseCode ResponseMessage }
            if let metaAny = raw["meta"], let metaDict = metaAny as? DataDict {
                let m = metaDict._data
                return APIResponseMeta(
                    status: m["status"] as? String,
                    responseCode: m["ResponseCode"] as? String,
                    responseMessage: m["ResponseMessage"] as? String,
                    requestId: m["RequestId"] as? String
                )
            }

            // 2) OLD SHAPE (not wrapped): status RequestId ResponseCode ResponseMessage
            if raw["ResponseCode"] != nil || raw["status"] != nil || raw["RequestId"] != nil || raw["ResponseMessage"] != nil {
                return APIResponseMeta(
                    status: raw["status"] as? String,
                    responseCode: raw["ResponseCode"] as? String,
                    responseMessage: raw["ResponseMessage"] as? String,
                    requestId: raw["RequestId"] as? String
                )
            }

            // 3) Recurse into children (handles calling this on root Query.Data)
            for child in raw.values {
                if let found = _findMeta(in: child, depth: depth - 1) { return found }
            }
            return nil
        }

        if let array = value as? [Any?] {
            for element in array {
                if let found = _findMeta(in: element, depth: depth - 1) { return found }
            }
            return nil
        }

        return nil
    }
}
