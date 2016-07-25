//
//  SetDetailsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import ActionSheetPicker

class SetDetailsViewController: CardListViewController {

    // MARK: Variables
    var setOID:NSManagedObjectID?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: CardlistViewController
    override func getWikiSegueName() -> String {
        return "showSetWiki"
    }
    override func  getWikiURLString() -> String {
        let set = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(setOID!) as! Set
        return "http://mtgsalvation.gamepedia.com/\(set.nameSnakeCase!)"
    }
    override func getCellTitle() -> String {
        let set = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(setOID!) as! Set
        return set.name!
    }
    override func getNavigationTitle() -> String {
        return "Set Wiki"
    }
    
    override func loadCards(predicate: NSPredicate?) {
        var cardPredicate:NSPredicate?
        var sorters:[NSSortDescriptor]?
        
        if let setOID = setOID {
            if let set = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(setOID) as? Set {
                cardPredicate = NSPredicate(format: "set.code == %@", set.code!)
            }
        }
        
        if let cp = cardPredicate,
            let p = predicate {
            cardPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [cp, p])
        }
        
        switch sortMode! {
        case .ByName:
            sorters = [NSSortDescriptor(key: "name", ascending: true)]
        case .ByColor:
            sorters = [NSSortDescriptor(key: "colorSection.name", ascending: true)]
        case .ByType:
            sorters = [NSSortDescriptor(key: "type.name", ascending: true)]
        case .ByRarity:
            sorters = [NSSortDescriptor(key: "rarity.name", ascending: true)]
        }
        
        fetchRequest = NSFetchRequest(entityName: "Card")
        fetchRequest!.predicate = cardPredicate
        fetchRequest!.sortDescriptors = sorters
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
    }
}


