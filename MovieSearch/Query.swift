//
//  Query.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/13/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import Foundation

enum Constants {
    static let apiKey = "ef233be4"
    private static let _baseDataRequest = "http://www.omdbapi.com/?apikey={KEY}&"
    private static let _basePosterRequest = "http://img.omdbapi.com/?apikey={KEY}&"
    
    case dataRequest, posterRequest
    
    func baseRequest() -> String {
        var base: String
        switch self {
        case .dataRequest:   base = Constants._baseDataRequest
        case .posterRequest: base = Constants._basePosterRequest
        }
        
        let finished = base.replacingOccurrences(of: "{KEY}", with: Constants.apiKey)
        
        return finished
    }
}

protocol Query {
}
