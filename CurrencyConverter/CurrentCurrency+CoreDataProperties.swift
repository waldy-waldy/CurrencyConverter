//
//  CurrentCurrency+CoreDataProperties.swift
//  
//
//  Created by neoviso on 9/9/21.
//
//

import Foundation
import CoreData


extension CurrentCurrency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentCurrency> {
        return NSFetchRequest<CurrentCurrency>(entityName: "CurrentCurrency")
    }

    @NSManaged public var codeFrom: String?
    @NSManaged public var codeTo: String?
    @NSManaged public var lastValue: Double

}
