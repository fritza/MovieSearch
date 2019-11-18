//
//  SearchGroup+CoreDataClass.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/17/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(SearchGroup)
public class SearchGroup: NSManagedObject {
    static let className = "SearchGroup"
    
    // MARK: Inertion
    /// Create a `SearchGroup` from the corresponding `Query`
    /// - Parameter query: The `Query` actually sent to the OMDb server.
    static func new(from query: Query) -> SearchGroup {
        guard let retval = NSEntityDescription.insertNewObject(
            forEntityName: className, into: gManagedObjectContext) as? SearchGroup else {
                fatalError(#function + " - can't insert")
        }
        
        guard let qType = query.type as? String  else { fatalError("Should not have an unassigned type") }
        
        retval.titleFragment    = (query.s as? String) ?? ""
        retval.year             = (query.y as? Int64) ?? 0
        retval.movieType        = qType
        
        // FIXME: save()'s throwing Can't Happen.
        try! gManagedObjectContext.save()
        
        return retval
    }
    
    // MARK: Result insertion
    /// Relate `SearchResult` managed objects to this query.
    /// - Parameter results: Array of `SearchResult`s to insert in my set of results.
    func addResults(_ results: [SearchResult]) {
        let resultSet = Set(results) as NSSet
        self.addToAllResults(resultSet)
        
        try! gManagedObjectContext.save()
    }
    
    func addResults(_ results: [SearchElement]) {
        let cdResults = results
            .filter { !SearchResult.storeAlreadyContains(imdbID: $0.imdbID) }
            .map { SearchResult.new(from: $0) }
        addResults(cdResults)
    }
}
