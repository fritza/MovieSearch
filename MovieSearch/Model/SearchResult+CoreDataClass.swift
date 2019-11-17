//
//  SearchResult+CoreDataClass.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/17/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(SearchResult)
public class SearchResult: NSManagedObject {
    static let className = "SearchResult"
    
    /// Insert a `SearchResult` constructed from a per-movie record returned by OMDb
///
    /// If a `SearchResult` managed object already exists, as determined by `imdbID`, return the existing object.
    ///
    /// By default the MOC is not saved, on the theiry that the owning `SearchGroup` is inserting a batch and can commit them _en masse._
    /// - Parameters:
    ///     - element: The record returned from OMDb.
    ///     - save: Whether to save the MOC once the new element is initialized. Default `false`.
    static func new(from element: SearchElement, save: Bool = false) -> SearchResult {
        // Trivially succeed if there's a record with the same IMDB ID
        if let existingObject = oneInstance(of: element.imdbID) { return existingObject }
        
        guard let retval = NSEntityDescription.insertNewObject(
            forEntityName: className, into: gManagedObjectContext) as? SearchResult else {
                fatalError(#function + " - can't insert")
        }
        
        retval.title = element.title
        retval.year = Int64(element.year)
        retval.imdbID = element.imdbID
        retval.type = element.type
        retval.posterURL = (element.posterURLString == "N/A") ? nil : URL(string: element.posterURLString)
        
        if save {
            // FIXME: save()'s throwing Can't Happen.
            try! gManagedObjectContext.save()
        }
        
        return retval
    }
    
    /// Whether a `SearchResult` is already in the store, as determined by the `imdbID`.`
    /// - Parameter imdbID: the IMDB identifier to check
    /// - note: Deprecated. Probably.
    static func storeAlreadyContains(imdbID: String?) -> Bool {
        guard let imdbID = imdbID else { return false }
        
        let fetch: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        fetch.predicate = NSPredicate(format: "imdbID = %@", imdbID)
        
        // FIXME: count(for:)'s throwing Can't Happen.
        let count = try! gManagedObjectContext.count(for: fetch)
        assert(count < 2,
               "\(#function) - got \(count) instances of imdbID \(imdbID)")
        return count == 1
    }
    
    /// Any instance of `SearchResult` in the store that has a given `imdbID`.
    /// - Parameter imdbID: The IMDB ID to search for
    /// - returns: `nil` if no such managed object yet exists.
    static func oneInstance(of imdbID: String?) -> SearchResult? {
        guard let imdbID = imdbID else { return nil }
        let fetch: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        fetch.predicate = NSPredicate(format: "imdbID = %@", imdbID)
        fetch.fetchLimit = 1
        
        // FIXME: fetch()'s throwing Can't Happen.
        let instances = try! gManagedObjectContext.fetch(fetch)
        return instances.first
    }
}
