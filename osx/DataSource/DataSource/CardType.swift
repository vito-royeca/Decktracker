//
//  CardType.swift
//  DataSource
//
//  Created by Jovit Royeca on 29/06/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class CardType: NSManagedObject {

    static let CardTypesWithSymbol      = ["Artifact",
                                           "Creature",
                                           "Enchantment",
                                           "Instant",
                                           "Land",
                                           "Planeswalker",
                                           "Sorcery"]
    struct Keys {
        static let Name = "name"
        static let Type = "type"
        static let Supertypes = "supertypes"
        static let Types = "types"
        static let Subtypes = "subtypes"
        static let OriginalType = "originalType"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("CardType", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        name = dictionary[Keys.Name] as? String
    }

}
