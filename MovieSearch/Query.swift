//
//  Query.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/13/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import Foundation
import Alamofire

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
    
    mutating func urlString(page: Int = 1) -> String? {
        self.page = page
        guard let dictionary = asDictionary else { return nil }
        
        let urlParams = dictionary.map {
            pair in
            return "\(pair.0)=\(String(describing: pair.1))"
        }
        .joined(separator: "&")
        
        return Constants.baseRequest + urlParams
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
    
    mutating func url(page: Int = 1) -> URL? {
        guard let string = urlString(page: page) else { return nil }
        return URL(string: string)
    }
    
    /// The parameters as a `URL` for the query
    ///
    /// `nil` if `isComplete` is `false``
    var url: URL? {
        guard let string = urlString else { return nil }
        return URL(string:string)
    }
}

let MovieResultsArrived = NSNotification.Name("movie results arrived")
let MovieFetchCompleted = NSNotification.Name("movie fetch completed")
let MovieResultsCleared = NSNotification.Name("movie results cleared")
let MovieFetchFailed = NSNotification.Name("movie fetch failed")
let fetchErrorKey = "fetch error key"
let resultCountKey = "result count"

class MovieLoader {
    var query: Query
    var totalCount: Int
    var initialCount: Int
    var error: Error?
    
    var searchResults = Array<SearchElement>()
    func append(results: [SearchElement]) {
        self.searchResults += results
        NotificationCenter.default
            .post(name: MovieResultsArrived, object: self,
                  userInfo: [resultCountKey: self.initialCount])
        // Clients are responsible for directing their UI actions to the main opersation queue
    }
    
    func clear() {
        DispatchQueue.global(qos: .background).async {
            self.searchResults = []
            self.error = nil
            self.totalCount = 0
            self.initialCount = 0
            NotificationCenter.default
                .post(name: MovieResultsCleared, object: self)
            // Clients are responsible for directing their UI actions to the main opersation queue
        }
    }
    
    static let decoder = JSONDecoder()
    
    init(query: Query) {
        self.query = query
        self.totalCount = 0
        self.initialCount = 0
    }
    
    /// Ask the DB for the `number`th page of search results.
    /// - Parameter number: The ordinal in a series of 10-line lists of movies.
    func request(page number: Int) {
        // TODO: Keep some kind of token for cancelling fetches.
        // TODO: AF takes care of timeouts. Do I need ot set a custom one?
        
        let urlPageN = query.url(page: number)
//        print("URL for page", number, "is", urlPageN ?? "NONE")
        Alamofire.request(urlPageN!)
            .responseData { (response) in
                switch response.result {
                case .success(let data):
                    do {
                        // Got data. Decode it.
                        let result = try MovieLoader.decoder.decode(SearchResponse.self, from: data)
                        self.append(results: result.search)
                        // Make totalCount the grand total less this batch
                        if number == 1 {
                            self.totalCount = result.totalResults
                            self.initialCount = result.totalResults
                        }
                        self.totalCount -= result.search.count
                        if self.totalCount > 0 && result.search.count > 0 {
                            self.request(page: number+1)
                        }
                        else {
                            // No more? Tell clients we're done.
                            NotificationCenter.default
                                .post(name: MovieFetchCompleted,
                                      object: self)
                        }
                    }
                    catch {
                        // Decoding didn't work.
                        // This may be to be expected, as JSONDecoder is fragile against unexpected JSON.
                        // … especially if you try to make everything non-optional.
                        self.error = error
                        self.totalCount = 0 // Can't hurt to set an additional condition to stop the cycle.
                        #if false
                        NotificationCenter.default
                            .post(name: MovieFetchFailed,
                                  object: self,
                                  userInfo: [fetchErrorKey: error])
                        #else
                        NotificationCenter.default
                            .post(name: MovieFetchCompleted,
                                  object: self)
                        #endif
                    }
                    
                    /* ========================================================================================== */
                    
                case .failure(let error):
                    self.error = error
                    self.totalCount = 0 // Can't hurt to set an additional condition to stop the cycle.
                    // How the UI tells the user is no business of Foundation-only code
                    NotificationCenter.default
                        .post(name: MovieFetchFailed,
                              object: self,
                              userInfo: [fetchErrorKey: error])
                    break
                }
        }
    }
    
    
    func start() {
        self.searchResults = []
        self.totalCount = 0
        request(page: 1)
    }
}



