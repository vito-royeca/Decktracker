//
//  Set.swift
//  DataSource
//
//  Created by Jovit Royeca on 29/06/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Set: NSManagedObject {

    struct Keys {
        static let Name = "name"
        static let Code = "code"
        static let GathererCode = "gathererCode"
        static let MagicCardsInfoCode = "magicCardsInfoCode"
        static let OldCode = "oldCode"
        static let OnlineOnly = "onlineOnly"
        static let ReleaseDate = "releaseDate"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Set", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        name = dictionary[Keys.Name] as? String
        code = dictionary[Keys.Code] as? String
        gathererCode = dictionary[Keys.GathererCode] as? String
        magicCardsInfoCode = dictionary[Keys.MagicCardsInfoCode] as? String
        oldCode = dictionary[Keys.OldCode] as? String
        onlineOnly = dictionary[Keys.OnlineOnly] as? NSNumber

        if let rd = dictionary[Keys.ReleaseDate] as? String {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            releaseDate = formatter.dateFromString(rd)
        }
    }

    var nameKeyPath: String? {
        if let name = name {
            let letters = NSCharacterSet.letterCharacterSet()
            
            for initial in name.unicodeScalars {
                if letters.longCharacterIsMember(initial.value) {
                    return "\(name[name.startIndex])".uppercaseString
                    
                } else {
                    return "#"
                }
            }
        }
        
        return nil
    }
    
    var typeKeyPath: String? {
        if let type = type {
            return type.name!.capitalizedString
        }
        
        return nil
    }
    
    var yearKeyPath: String? {
        if let releaseDate = releaseDate {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "YYYY"
            
            return formatter.stringFromDate(releaseDate)
        }
        
        return nil
    }
}
