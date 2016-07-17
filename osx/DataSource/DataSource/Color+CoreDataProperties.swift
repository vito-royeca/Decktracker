//
//  CardColor+CoreDataProperties.swift
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

extension Color {

    @NSManaged var name: String?
    @NSManaged var symbol: String?
    @NSManaged var cards: NSSet?
    @NSManaged var colorSections: NSSet?
    @NSManaged var identities: NSSet?

}
