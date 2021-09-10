//
//  CurrencyEntity+CoreDataProperties.swift
//  
//
//  Created by neoviso on 9/10/21.
//
//

import Foundation
import CoreData


extension CurrencyEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyEntity> {
        return NSFetchRequest<CurrencyEntity>(entityName: "CurrencyEntity")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var rate: Double

}
