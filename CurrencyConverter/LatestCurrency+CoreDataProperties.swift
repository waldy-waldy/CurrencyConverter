//
//  LatestCurrency+CoreDataProperties.swift
//  
//
//  Created by neoviso on 9/9/21.
//
//

import Foundation
import CoreData


extension LatestCurrency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LatestCurrency> {
        return NSFetchRequest<LatestCurrency>(entityName: "LatestCurrency")
    }

    @NSManaged public var code: String?
    @NSManaged public var date: Date?
    @NSManaged public var name: String?

}
