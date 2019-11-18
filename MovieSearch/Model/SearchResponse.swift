//
//  SearchResponse.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/17/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import Foundation

private let formatter: NumberFormatter = {
    let retval = NumberFormatter()
    return retval
}()

private func numberOrZero(from str: String) -> Int {
    return formatter.number(from: str)?.intValue ?? 0
}

struct SearchElement: Decodable {
    let title: String // "Title"
    let _year: String      // "Year" -> reported as String
    let imdbID: String
    let type: String // "Type"
    let posterURLString: String // "Poster"
    
    var year: Int {
        return numberOrZero(from: _year)
    }
    var posterURL: URL? {
        guard !posterURLString.isEmpty && posterURLString != "N/A" else { return nil }
        return URL(string: posterURLString)
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case _year = "Year"
        case imdbID
        case type = "Type"
        case posterURLString = "Poster"
    }
}

struct SearchResponse: Decodable {
    var search: [SearchElement]    // "Search"
    let _totalResults: String
    let _response: String // key is "Response"
    
    var totalResults: Int { return numberOrZero(from: _totalResults) }
    var response: Bool { return _response.lowercased().hasPrefix("t") }
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case _totalResults = "totalResults"
        case _response = "Response"
    }
    
    static let srDecoder = JSONDecoder()
    static func from(data: Data) -> SearchResponse? {
        do {
            let result = try srDecoder.decode(SearchResponse.self, from: data)
            return result
        }
        catch {
            print(#function, "didn't decode:", error)
        }
        return nil
    }
}



