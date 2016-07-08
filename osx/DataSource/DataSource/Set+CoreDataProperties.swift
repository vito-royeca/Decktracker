//
//  Set+CoreDataProperties.swift
//  DataSource
//
//  Created by Jovit Royeca on 29/06/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Set {

    @NSManaged var code: String?
    @NSManaged var gathererCode: String?
    @NSManaged var magicCardsInfoCode: String?
    @NSManaged var name: String?
    @NSManaged var numberOfCards: NSNumber?
    @NSManaged var oldCode: String?
    @NSManaged var onlineOnly: NSNumber?
    @NSManaged var releaseDate: NSDate?
    @NSManaged var tcgPlayerName: String?
    @NSManaged var block: Block?
    @NSManaged var border: Border?
    @NSManaged var cards: NSSet?
    @NSManaged var type: SetType?
    @NSManaged var printings: NSSet?

}
