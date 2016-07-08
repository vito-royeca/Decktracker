//
//  Card+CoreDataProperties.swift
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

extension Card {

    @NSManaged var cardID: String?
    @NSManaged var name: String?
    @NSManaged var manaCost: String?
    @NSManaged var cmc: NSNumber?
    @NSManaged var text: String?
    @NSManaged var flavor: String?
    @NSManaged var number: String?
    @NSManaged var power: String?
    @NSManaged var toughness: String?
    @NSManaged var loyalty: NSNumber?
    @NSManaged var multiverseID: NSNumber?
    @NSManaged var imageName: String?
    @NSManaged var timeshifted: NSNumber?
    @NSManaged var hand: NSNumber?
    @NSManaged var life: NSNumber?
    @NSManaged var reserved: NSNumber?
    @NSManaged var releaseDate: String?
    @NSManaged var starter: NSNumber?
    @NSManaged var originalText: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var set: NSManagedObject?
    @NSManaged var layout: NSManagedObject?
    @NSManaged var colors: NSSet?
    @NSManaged var colorIdentity: NSSet?
    @NSManaged var type: NSManagedObject?
    @NSManaged var supertypes: NSSet?
    @NSManaged var subtypes: NSSet?
    @NSManaged var types: NSSet?
    @NSManaged var rarity: NSManagedObject?
    @NSManaged var artist: NSManagedObject?
    @NSManaged var variations: NSSet?
    @NSManaged var watermark: CardWatermark?
    @NSManaged var border: NSManagedObject?
    @NSManaged var rulings: NSSet?
    @NSManaged var foreignNames: NSSet?
    @NSManaged var printings: NSSet?
    @NSManaged var originalType: NSManagedObject?
    @NSManaged var legalities: NSSet?
    @NSManaged var source: NSManagedObject?
    @NSManaged var ratings: NSSet?

}
