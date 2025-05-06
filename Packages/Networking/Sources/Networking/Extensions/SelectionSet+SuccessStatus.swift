//
//  StatusSuccess.swift
//  Networking
//
//  Created by Alexander Savchenko on 02.04.25.
//

import ApolloAPI

extension SelectionSet {
    var isSuccessStatus: Bool {
        guard let dataDictionary = self.__data._data.values.first as? DataDict,
              let statusValue: String = dataDictionary["status"] else {
            return false
        }
        
        return statusValue == "success"
    }

    var getResponseCode: String? {
        guard
            let dataDictionary = self.__data._data.values.first as? DataDict,
            let codeStringValue: String = dataDictionary["ResponseCode"]
        else {
            return nil
        }
        
        return codeStringValue
    }

    var isResponseCodeSuccess: Bool {
        guard
            let codeStringValue = getResponseCode,
            let firstChar = codeStringValue.first,
            let firstResponseCodeNumber = Int(String(firstChar)),
            firstResponseCodeNumber == 1
        else {
            return false
        }

        return true
    }
}
