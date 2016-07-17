//
//  TCGPlayerPricing+CoreDataProperties.swift
//  DataSource
//
//  Created by Jovit Royeca on 14/07/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TCGPlayerPricing {

    @NSManaged var fetchDate: NSDate?
    @NSManaged var foilPrice: NSNumber?
    @NSManaged var highPrice: NSNumber?
    @NSManaged var link: String?
    @NSManaged var lowPrice: NSNumber?
    @NSManaged var midPrice: NSNumber?
    @NSManaged var card: Card?

}
