//
//  CardColor.swift
//  DataSource
//
//  Created by Jovit Royeca on 29/06/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Color: NSManagedObject {

    struct Keys {
        static let Name = "name"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Color", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        name = dictionary[Keys.Name] as? String
        
        if let name = name {
            if name == "Black" {
                symbol = "B"
            } else if name == "Blue" {
                symbol = "U"
            } else if name == "Green" {
                symbol = "G"
            } else if name == "Red" {
                symbol = "R"
            } else if name == "White" {
                symbol = "W"
            } else if name == "Colorless" {
                symbol = "C"
            }
        }
    }

}
