//
//  ObjectManager.swift
//   WTHRM8
//
//  Created by Jovit Royeca on 18/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import CoreData

class ObjectManager: NSObject {

    // MARK: Constants
    static let BatchUpdateNotification = "BatchUpdateNotification"
    
    // MARK: Variables
    private var privateContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.privateContext
    }
    private var mainObjectContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.mainObjectContext
    }
    
    // Mark: Finder methods
    func findOrCreateColor(dict: [String: AnyObject]) -> Color {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Color in
            return Color(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Color", objectFinder: ["name": dict[Color.Keys.Name]!], initializer: initializer) as! Color
    }
    
    func findOrCreateSet(dict: [String: AnyObject]) -> Set {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Set in
            return Set(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Set", objectFinder: ["name": dict[Set.Keys.Name]!], initializer: initializer) as! Set
    }
    
    func findOrCreateBlock(dict: [String: AnyObject]) -> Block {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Block in
            return Block(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Block", objectFinder: ["name": dict[Block.Keys.Name]!], initializer: initializer) as! Block
    }
    
    func findOrCreateSetType(dict: [String: AnyObject]) -> SetType {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> SetType in
            return SetType(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "SetType", objectFinder: ["name": dict[SetType.Keys.Name]!], initializer: initializer) as! SetType
    }
    
    func findOrCreateBorder(dict: [String: AnyObject]) -> Border {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Border in
            return Border(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Border", objectFinder: ["name": dict[Border.Keys.Name]!], initializer: initializer) as! Border
    }
    
    func findOrCreateCard(dict: [String: AnyObject]) -> Card {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Card in
            return Card(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Card", objectFinder: ["cardID": dict[Card.Keys.CardID]!], initializer: initializer) as! Card
    }
    
    func findOrCreateLayout(dict: [String: AnyObject]) -> Layout {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Layout in
            return Layout(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Layout", objectFinder: ["name": dict[Layout.Keys.Name]!], initializer: initializer) as! Layout
    }
    
    func findOrCreateCardType(dict: [String: AnyObject]) -> CardType {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> CardType in
            return CardType(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "CardType", objectFinder: ["name": dict[CardType.Keys.Name]!], initializer: initializer) as! CardType
    }
    
    func findOrCreateRarity(dict: [String: AnyObject]) -> Rarity {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Rarity in
            return Rarity(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Rarity", objectFinder: ["name": dict[Rarity.Keys.Name]!], initializer: initializer) as! Rarity
    }
    
    func findOrCreateArtist(dict: [String: AnyObject]) -> Artist {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Artist in
            return Artist(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Artist", objectFinder: ["name": dict[Artist.Keys.Name]!], initializer: initializer) as! Artist
    }
    
    func findOrCreateWatermark(dict: [String: AnyObject]) -> Watermark {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Watermark in
            return Watermark(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Watermark", objectFinder: ["name": dict[Watermark.Keys.Name]!], initializer: initializer) as! Watermark
    }
    
    func findOrCreateSource(dict: [String: AnyObject]) -> Source {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Source in
            return Source(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Source", objectFinder: ["name": dict[Source.Keys.Name]!], initializer: initializer) as! Source
    }
    
    func findOrCreateFormat(dict: [String: AnyObject]) -> Format {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Format in
            return Format(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Format", objectFinder: ["name": dict[Format.Keys.Name]!], initializer: initializer) as! Format
    }
    
    func findOrCreateLegality(dict: [String: AnyObject]) -> Legality {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Legality in
            return Legality(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Legality", objectFinder: ["name": dict[Legality.Keys.Name]!], initializer: initializer) as! Legality
    }
    
    func findOrCreateRuling(card: Card, dict: [String: AnyObject]) -> Ruling {
        
        let ruling = Ruling(dictionary: dict, context: privateContext)
        ruling.card = card
        CoreDataManager.sharedInstance.savePrivateContext()
        
        return ruling
    }
    
    func findOrCreateCardLegality(card: Card, dict: [String: AnyObject]) -> CardLegality {
        let cardLegality = CardLegality(context: privateContext)
        cardLegality.card = card
        cardLegality.format = findOrCreateFormat(dict)
        cardLegality.legality = findOrCreateLegality(dict)
        
        return cardLegality
    }
    
    func findOrCreateLanguage(dict: [String: AnyObject]) -> Language {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Language in
            return Language(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Language", objectFinder: ["name": dict[Language.Keys.Name]!], initializer: initializer) as! Language
    }
    
    func findOrCreateForeignName(card: Card, dict: [String: AnyObject]) -> ForeignName {
        let cardForeignName = ForeignName(dictionary: dict, context: privateContext)
        cardForeignName.card = card
        cardForeignName.language = findOrCreateLanguage(dict)
        
        return cardForeignName
    }
    
    func findOrCreateTCGPlayerPricing(card: Card, dict: [String: AnyObject]) -> TCGPlayerPricing {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> TCGPlayerPricing in
            return TCGPlayerPricing(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "TCGPlayerPricing", objectFinder: ["card.cardID": card.cardID!], initializer: initializer) as! TCGPlayerPricing
    }
    
    // MARK: Core methods
    
    func findOrCreateObject(dict: [String: AnyObject], entityName: String, objectFinder: [String: AnyObject], initializer: (dict: [String: AnyObject], context: NSManagedObjectContext) -> AnyObject) -> AnyObject {
        var object:AnyObject?
        var predicate:NSPredicate?
        
        for (key,value) in objectFinder {
            if predicate != nil {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, NSPredicate(format: "%K == %@", key, value as! NSObject)])
            } else {
                predicate = NSPredicate(format: "%K == %@", key, value as! NSObject)
            }
        }
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        do {
            if let m = try privateContext.executeFetchRequest(fetchRequest).first {
                object = m
                
            } else {
                object = initializer(dict: dict, context: privateContext)
                CoreDataManager.sharedInstance.savePrivateContext()
            }
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return object!
    }

    func findObjects(entityName: String, predicate: NSPredicate?, sorters: [NSSortDescriptor]) -> [AnyObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sorters
        
        var objects:[AnyObject]?
        
        do {
            objects = try privateContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return objects!
    }
    
    func fetchObjects(fetchRequest: NSFetchRequest) -> [AnyObject] {
        var objects:[AnyObject]?
        
        do {
            objects = try privateContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return objects!
    }
    
    func deleteObjects(entityName: String, objectFinder: [String: AnyObject]) {
        var predicate:NSPredicate?
        for (key,value) in objectFinder {
            if predicate != nil {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, NSPredicate(format: "%K == %@", key, value as! NSObject)])
            } else {
                predicate = NSPredicate(format: "%K == %@", key, value as! NSObject)
            }
        }
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        do {
            if let m = try privateContext.executeFetchRequest(fetchRequest).first as? NSManagedObject {
                privateContext.deleteObject(m)
                CoreDataManager.sharedInstance.savePrivateContext()
                
            }
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = ObjectManager()
}
