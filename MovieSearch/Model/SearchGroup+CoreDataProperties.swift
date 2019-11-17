//
//  SearchGroup+CoreDataProperties.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/17/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//
//

import Foundation
import CoreData


extension SearchGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchGroup> {
        return NSFetchRequest<SearchGroup>(entityName: "SearchGroup")
    }

    @NSManaged public var titleFragment: String?
    @NSManaged public var year: Int64
    @NSManaged public var movieType: String?
    @NSManaged public var allResults: NSSet?

}

// MARK: Generated accessors for allResults
extension SearchGroup {

    @objc(addAllResultsObject:)
    @NSManaged public func addToAllResults(_ value: SearchResult)

    @objc(removeAllResultsObject:)
    @NSManaged public func removeFromAllResults(_ value: SearchResult)

    @objc(addAllResults:)
    @NSManaged public func addToAllResults(_ values: NSSet)

    @objc(removeAllResults:)
    @NSManaged public func removeFromAllResults(_ values: NSSet)

}
