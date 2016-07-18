//
//  Card.swift
//  DataSource
//
//  Created by Jovit Royeca on 29/06/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Card: NSManagedObject {

    struct Keys {
        static let CardID = "id"
        static let Name = "name"
        static let ManaCost = "manaCost"
        static let CMC = "cmc"
        static let Text = "text"
        static let Flavor = "flavor"
        static let Number = "number"
        static let Power = "power"
        static let Toughness = "toughness"
        static let Loyalty = "loyalty"
        static let MultiverseID = "multiverseid"
        static let ImageName = "imageName"
        static let Timeshifted = "timeshifted"
        static let Hand = "hand"
        static let Life = "life"
        static let Reserved = "reserved"
        static let ReleaseDate = "releaseDate"
        static let Starter = "starter"
        static let OrginalText = "originalText"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Card", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        cardID = dictionary[Keys.CardID] as? String
        name = dictionary[Keys.Name] as? String
        manaCost = dictionary[Keys.ManaCost] as? String
        cmc = dictionary[Keys.CMC] as? NSNumber
        text = dictionary[Keys.Text] as? String
        flavor = dictionary[Keys.Flavor] as? String
        number = dictionary[Keys.Number] as? String
        power = dictionary[Keys.Power] as? String
        toughness = dictionary[Keys.Toughness] as? String
        loyalty = dictionary[Keys.Loyalty] as? NSNumber
        multiverseID = dictionary[Keys.MultiverseID] as? NSNumber
        imageName = dictionary[Keys.ImageName] as? String
        timeshifted = dictionary[Keys.Timeshifted] as? NSNumber
        hand = dictionary[Keys.Hand] as? NSNumber
        life = dictionary[Keys.Life] as? NSNumber
        reserved = dictionary[Keys.Reserved] as? NSNumber
        releaseDate = dictionary[Keys.ReleaseDate] as? String
        starter = dictionary[Keys.Starter] as? NSNumber
        originalText = dictionary[Keys.OrginalText] as? String
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

    var colorKeyPath: String? {
        if let colorSection = colorSection {
            return colorSection.name!.capitalizedString
        }
        
        return nil
    }
    
    var typeKeyPath: String? {
        if let type = type {
            return type.name!.capitalizedString
        }
        
        return nil
    }
    
    var rarityKeyPath: String? {
        if let rarity = rarity {
            return rarity.name!.capitalizedString
        }
        
        return nil
    }
    
    var cropPath: NSURL? {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let cacheDirectory = paths.first
        let path = "\(cacheDirectory!)/images/crop/\(set!.code!)/\(cardID!).crop.hq.jpg"
        return NSURL(string: path)
    }
    
    var typePath: NSURL? {
        if let type = type {
            var path:String?
            
            for t in CardType.CardTypesWithSymbol {
                if type.name!.hasPrefix(t) || type.name!.containsString(t) {
                    path = t.lowercaseString
                }
            }
            if let path = path {
                return NSURL(string: "\(NSBundle.mainBundle().bundlePath)/images/other/\(path)/32.png")
            }
        }
        
        return nil
    }
    
    var urlPath: NSURL? {
        if let magicCardsInfoCode = set!.magicCardsInfoCode,
            let number = number {
            return NSURL(string: "http://magiccards.info/scans/en/\(magicCardsInfoCode)/\(number).jpg")!
        }
        
        return nil
    }
}
