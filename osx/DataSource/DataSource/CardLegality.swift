//
//  CardLegality.swift
//  DataSource
//
//  Created by Jovit Royeca on 01/07/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class CardLegality: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("CardLegality", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
    }
    
    var legalityKeyPath: String? {
        if let legality = legality {
            return legality.name!.capitalizedString
        }
        
        return nil
    }

}
