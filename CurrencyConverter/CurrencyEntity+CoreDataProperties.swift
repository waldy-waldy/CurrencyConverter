//
//  CurrencyEntity+CoreDataProperties.swift
//  
//
//  Created by neoviso on 9/3/21.
//
//

import Foundation
import CoreData


extension CurrencyEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyEntity> {
        return NSFetchRequest<CurrencyEntity>(entityName: "CurrencyEntity")
    }

    @NSManaged public var currencyName: String?
    @NSManaged public var currencyValue: Double
    @NSManaged public var isSell: Bool

}
