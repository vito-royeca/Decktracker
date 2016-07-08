//
//  JSONLoader.swift
//  DataSource
//
//  Created by Jovit Royeca on 29/06/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

class JSONLoader: NSObject {

    let eightEditionRelease = "2003-07-28"
    var eightEditionReleaseDate:NSDate?
    
    func json2Database() {
        let filePath = "\(NSBundle.mainBundle().resourcePath!)/Data/AllSets-x.json"
        print("filePath=\(filePath)")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        eightEditionReleaseDate = dateFormatter.dateFromString(eightEditionRelease)
        
        CoreDataManager.sharedInstance.setup(Constants.CoreDataSQLiteFile, modelFile: Constants.CoreDataModelFile)
        
        // Create additional CardColors
        ObjectManager.sharedInstance.findOrCreateColor(["name": "Colorless"])
        ObjectManager.sharedInstance.findOrCreateColor(["name": "Multicolored"])

        if let data = NSData(contentsOfFile: filePath) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data,  options:.MutableContainers)
            
                if let dict = json as? [String: AnyObject] {
                    
                    // parse the sets
                    for setName in dict.keys {
                        if let dictSets = dict[setName] as? [String: AnyObject] {
                            parseSet(dictSets)
                        }
                    }
                    
                    // parse the cards
                    for setName in dict.keys {
                        if let dictSets = dict[setName] as? [String: AnyObject] {
                            let set = parseSet(dictSets)
//                            if set.code != "LEA" {
//                                continue
//                            }
                            
                            if let dictCards = dictSets["cards"] as? [[String: AnyObject]] {
                                let cards = parseCards(dictCards, forSet: set)
                                set.numberOfCards = NSNumber(integer: cards.count)
                                CoreDataManager.sharedInstance.saveMainContext()
                            }
                        }
                    }
                    
                    // parse extra info
                    for setName in dict.keys {
                        if let dictSets = dict[setName] as? [String: AnyObject] {
                            if let dictCards = dictSets["cards"] as? [[String: AnyObject]] {
                                parseVariations(dictCards)
                                parseRulings(dictCards)
                                parseLegalities(dictCards)
                                parseForeignNames(dictCards)
                            }
                        }
                    }
                }
            } catch {
                
            }
        }
        
        CoreDataManager.sharedInstance.saveMainContext()
    }
    
    func parseSet(dict: [String: AnyObject]) -> Set {
        let set = ObjectManager.sharedInstance.findOrCreateSet(dict)
        
        if let _ = dict[Block.Keys.Name] as? String {
            set.block = ObjectManager.sharedInstance.findOrCreateBlock(dict)
        }
        if let _ = dict[Border.Keys.Name] as? String {
            set.border = ObjectManager.sharedInstance.findOrCreateBorder(dict)
        }
        if let _ = dict[SetType.Keys.Name] as? String {
            set.type = ObjectManager.sharedInstance.findOrCreateSetType(dict)
        }
        set.tcgPlayerName = getTcgPlayerName(set)
        
        CoreDataManager.sharedInstance.savePrivateContext()
        return set
    }
    
    func getTcgPlayerName(set: Set) -> String? {
    
        let filePath = "\(NSBundle.mainBundle().resourcePath!)/Data/tcgplayer_sets.plist"
        if let dict = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject] {
            if let tcgPlayerName = dict[set.name!] as? String {
                return tcgPlayerName
            }
        }
        
        return nil
    }
    
    func parseCards(dict: [[String: AnyObject]], forSet set: Set) -> [Card] {
        var cards = [Card]()
        
        for dictCard in dict {
            let card = ObjectManager.sharedInstance.findOrCreateCard(dictCard)
            
            card.set = set
            if let _ = dictCard[Layout.Keys.Name] as? String {
                card.layout = ObjectManager.sharedInstance.findOrCreateLayout(dictCard)
            }
            if let dictColors = dictCard["colors"] as? [String] {
                let colors = card.mutableSetValueForKey("colors")
                
                for color in dictColors {
                    let cardColor = ObjectManager.sharedInstance.findOrCreateColor([Color.Keys.Name: color])
                    colors.addObject(cardColor)
                }
            }
            if let dictColorIdentity = dictCard["colorIdentity"] as? [String] {
                let colorIdentities = card.mutableSetValueForKey("colors")
                
                for symbol in dictColorIdentity {
                    let predicate = NSPredicate(format: "symbol == %@", symbol)
                    
                    if let cardColor = ObjectManager.sharedInstance.findObjects("Color", predicate: predicate, sorters: [NSSortDescriptor(key: "name", ascending: true)]).first {
                        colorIdentities.addObject(cardColor)
                    }
                }
            }
            if let type = dictCard[CardType.Keys.Type] as? String {
                card.type = ObjectManager.sharedInstance.findOrCreateCardType([CardType.Keys.Name: type])
            }
            if let dictSupertypes = dictCard[CardType.Keys.Supertypes] as? [String] {
                let supertypes = card.mutableSetValueForKey(CardType.Keys.Supertypes)
                
                for supertype in dictSupertypes {
                    let cardSupertype = ObjectManager.sharedInstance.findOrCreateCardType([CardType.Keys.Name: supertype])
                    supertypes.addObject(cardSupertype)
                }
            }
            if let dictSubtypes = dictCard[CardType.Keys.Subtypes] as? [String] {
                let subtypes = card.mutableSetValueForKey(CardType.Keys.Subtypes)
                
                for subtype in dictSubtypes {
                    let cardSubtype = ObjectManager.sharedInstance.findOrCreateCardType([CardType.Keys.Name: subtype])
                    subtypes.addObject(cardSubtype)
                }
            }
            if let dictTypes = dictCard[CardType.Keys.Types] as? [String] {
                let types = card.mutableSetValueForKey(CardType.Keys.Types)
                
                for type in dictTypes {
                    let cardType = ObjectManager.sharedInstance.findOrCreateCardType([CardType.Keys.Name: type])
                    types.addObject(cardType)
                }
            }
            if let _ = dictCard[Rarity.Keys.Name] as? String {
                card.rarity = ObjectManager.sharedInstance.findOrCreateRarity(dictCard)
            }
            if let _ = dictCard[Artist.Keys.Name] as? String {
                card.artist = ObjectManager.sharedInstance.findOrCreateArtist(dictCard)
            }
            if let _ = dictCard[Watermark.Keys.Name] as? String {
                card.watermark = ObjectManager.sharedInstance.findOrCreateWatermark(dictCard)
            }
            if let _ = dictCard[Border.Keys.Name] as? String {
                card.border = ObjectManager.sharedInstance.findOrCreateBorder(dictCard)
            }
            if let dictPrintings = dictCard["printings"] as? [String] {
                let printings = card.mutableSetValueForKey("printings")
                
                for printing in dictPrintings {
                    let predicate = NSPredicate(format: "code == %@", printing)
                    if let set = ObjectManager.sharedInstance.findObjects("Set", predicate: predicate, sorters: [NSSortDescriptor(key: "code", ascending: true)]).first {
                        printings.addObject(set)
                    }
                }
            }
            if let originalType = dictCard[CardType.Keys.OriginalType] as? String {
                card.originalType = ObjectManager.sharedInstance.findOrCreateCardType([CardType.Keys.Name: originalType])
            }
            if let _ = dictCard[Source.Keys.Name] as? String {
                card.source = ObjectManager.sharedInstance.findOrCreateSource(dictCard)
            }

            // if release date is greater than 8th Edition, card is modern
            if let releaseDate = card.releaseDate {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd"
                
                var actualReleaseDate:NSDate?
                
                if releaseDate.characters.count == 4 {
                    actualReleaseDate = dateFormatter.dateFromString("\(releaseDate)-01-01")
                } else if releaseDate.characters.count == 7 {
                    actualReleaseDate = dateFormatter.dateFromString("\(releaseDate)-01")
                } else {
                    actualReleaseDate = dateFormatter.dateFromString(releaseDate)
                }
                
                if let actualReleaseDate = actualReleaseDate,
                    eightEditionReleaseDate = eightEditionReleaseDate {
                    card.modern = NSNumber(bool: actualReleaseDate.compare(eightEditionReleaseDate) == .OrderedSame ||
                    actualReleaseDate.compare(eightEditionReleaseDate) == .OrderedDescending)
                }
                
            } else {
                if let releaseDate = card.set!.releaseDate,
                    eightEditionReleaseDate = eightEditionReleaseDate {
                    card.modern = NSNumber(bool: releaseDate.compare(eightEditionReleaseDate) == .OrderedSame ||
                        releaseDate.compare(eightEditionReleaseDate) == .OrderedDescending)
                }
            }
            
            print("\(card.name!) (\(card.set!.code!))")
            cards.append(card)
        }
        
        CoreDataManager.sharedInstance.savePrivateContext()
        return cards
    }
    
    func parseVariations(dict: [[String: AnyObject]]) {
        for dictCard in dict {
            if let dictVariations = dictCard["variations"] as? [NSNumber] {
                let card = ObjectManager.sharedInstance.findOrCreateCard(dictCard)
                let variations = card.mutableSetValueForKey("variations")
        
                print("\(card.name!)")
                for variation in dictVariations {
                    let predicate = NSPredicate(format: "multiverseID == %@", variation)
                    
                    if let cardVariation = ObjectManager.sharedInstance.findObjects("Card", predicate: predicate, sorters: [NSSortDescriptor(key: "multiverseID", ascending: true)]).first {
                        variations.addObject(cardVariation)
                        print("\t\(card.set!.code!)")
                    }
                }
            }
        }
        
        
        CoreDataManager.sharedInstance.savePrivateContext()
    }
    
    func parseRulings(dict: [[String: AnyObject]]) {
        for dictCard in dict {
            if let dictRulings = dictCard["rulings"] as? [[String: AnyObject]] {
                let card = ObjectManager.sharedInstance.findOrCreateCard(dictCard)
                let rulings = card.mutableSetValueForKey("rulings")
                let formatter = NSDateFormatter()
                
                formatter.dateFormat = "YYYY-MM-dd"
                print("\(card.name!)")
                for ruling in dictRulings {
                    let cardRuling = ObjectManager.sharedInstance.findOrCreateRuling(ruling)
                    rulings.addObject(cardRuling)
                    print("\t\(ruling["date"]!)")
                }
            }
        }
        
        CoreDataManager.sharedInstance.savePrivateContext()
    }
    
    func parseLegalities(dict: [[String: AnyObject]]) {
        for dictCard in dict {
            if let dictLegalities = dictCard["legalities"] as? [[String: AnyObject]] {
                let card = ObjectManager.sharedInstance.findOrCreateCard(dictCard)
                let legalities = card.mutableSetValueForKey("legalities")
                
                print("\(card.name!)")
                for legality in dictLegalities {
                    let cardLegality = ObjectManager.sharedInstance.findOrCreateCardLegality(card, dict: legality)
                    legalities.addObject(cardLegality)
                    print("\t\(cardLegality.format!.name!): \(cardLegality.legality!.name!)")
                }
            }
        }
        
        CoreDataManager.sharedInstance.savePrivateContext()
    }
    
    func parseForeignNames(dict: [[String: AnyObject]]) {
        for dictCard in dict {
            if let dictForeignNames = dictCard["foreignNames"] as? [[String: AnyObject]] {
                let card = ObjectManager.sharedInstance.findOrCreateCard(dictCard)
                let foreignNames = card.mutableSetValueForKey("foreignNames")
                
                print("\(card.name!)")
                for foreignName in dictForeignNames {
                    let cardForeignName = ObjectManager.sharedInstance.findOrCreateForeignName(card, dict: foreignName)
                    foreignNames.addObject(cardForeignName)
                    print("\t\(cardForeignName.language!.name!): \(cardForeignName.name!)")
                }
            }
        }
        
        CoreDataManager.sharedInstance.savePrivateContext()
    }
    
    // MARK: Utility methods

}
