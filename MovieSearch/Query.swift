//
//  Query.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/13/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import Foundation

enum Constants {
    static let momBaseName = "MovieSearch"
    static let apiKey = "ef233be4"
    private static let _baseDataRequest = "https://www.omdbapi.com/?apikey={KEY}&"
    static var baseRequest: String = {
        return Constants._baseDataRequest.replacingOccurrences(of: "{KEY}", with: Constants.apiKey)
    }()
    
    static var plainNumberFormatter: NumberFormatter = {
        return NumberFormatter()
    }()
}

// https://www.omdbapi.com/?apikey=ef233be4&i=tt0114924

/// Aggregate the parameters for an OMDb search.into a dictionary, `URL`, or URL string.
///
/// `r` (json)  and `type` (movie) are defaulted as per spec`
///
/// The output methods return `nil` if the parameter set isn't complete (`s` for title search, at this writing).
@dynamicMemberLookup
struct Query {
    /// Reject any parameter tags not in this set
    static let validTags: Set<String> = [
        "s", "type", "y", "r", "page", "callback", "v"
    ]
    
    /// Backing store for the result dictionary
    ///
    /// Use this for Alamofire's automatic parameter-setting methods.
    private (set) var parameters: [String:Any] = ["r": "json", "type": "movie"]
    
    /// Accept apparent property accesses to access the `parameters` backing dictionary.
    /// - precondition: The “property” name mist be in the `validTags` set.
    subscript(dynamicMember name: String) -> Any? {
        get { return parameters[name] }
        set {
            precondition(Query.validTags.contains(name))
            var valueToUse = newValue
            if let nv = newValue as? NSString {
                // FIXME: Store with spaces intact.
                //        Let the `urlString` renderer convert
                //        space to `+`, but leave the original
                //        in the backing store.
                valueToUse = nv.replacingOccurrences(of: " ", with: "+")
            }
            parameters[name] = valueToUse
        }
    }
    
    /// Whether the parameters are complete for submission.
    ///
    /// For now that means specifying a title, at all.
    var isComplete: Bool {
        return self.s != nil
    }
    
    /// The parameters in `Dictionary` form.
    ///
    /// `nil` if `isComplete` is `false`
    var asDictionary: [String:Any]? {
        return isComplete ? parameters : nil
    }
    
    /// The parameters rendered as an absolute URL path.
    ///
    /// `nil` if `isComplete` is `false``
    var urlString: String? {
        guard let dictionary = asDictionary else { return nil }
        
        let urlParams = dictionary.map {
            pair in
            return "\(pair.0)=\(String(describing: pair.1))"
        }
        .joined(separator: "&")
        
        return Constants.baseRequest + urlParams
    }
    
    /// The parameters as a `URL` for the query
    ///
    /// `nil` if `isComplete` is `false``
    var url: URL? {
        guard let string = urlString else { return nil }
        return URL(string:string)
    }
}

