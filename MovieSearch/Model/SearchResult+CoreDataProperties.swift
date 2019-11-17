//
//  SearchResult+CoreDataProperties.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/17/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//
//

import Foundation
import CoreData


extension SearchResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchResult> {
        return NSFetchRequest<SearchResult>(entityName: "SearchResult")
    }

    @NSManaged public var title: String
    @NSManaged public var year: Int64
    @NSManaged public var imdbID: String?
    @NSManaged public var type: String
    @NSManaged public var posterURL: URL?
    @NSManaged public var searchGroups: NSSet?

}

// MARK: Generated accessors for searchGroups
extension SearchResult {

    @objc(addSearchGroupsObject:)
    @NSManaged public func addToSearchGroups(_ value: SearchGroup)

    @objc(removeSearchGroupsObject:)
    @NSManaged public func removeFromSearchGroups(_ value: SearchGroup)

    @objc(addSearchGroups:)
    @NSManaged public func addToSearchGroups(_ values: NSSet)

    @objc(removeSearchGroups:)
    @NSManaged public func removeFromSearchGroups(_ values: NSSet)

}
