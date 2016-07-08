//
//  CardLegality+CoreDataProperties.swift
//  DataSource
//
//  Created by Jovit Royeca on 01/07/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CardLegality {

    @NSManaged var card: Card?
    @NSManaged var format: Format?
    @NSManaged var legality: Legality?

}
