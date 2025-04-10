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
}
