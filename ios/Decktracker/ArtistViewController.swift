//
//  ArtistViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 20/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

class ArtistViewController: CardListViewController {

    // MARK: Variables
    var artistOID: NSManagedObjectID?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CardlistViewController
    override func getWikiSegueName() -> String {
        return "showArtistWiki"
    }
    override func  getWikiURLString() -> String {
        let artist = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(artistOID!) as! Artist
        return "http://mtgsalvation.gamepedia.com/\(artist.nameSnakeCase!)"
    }
    override func getCellTitle() -> String {
        let artist = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(artistOID!) as! Artist
        return artist.name!
    }
    override func getNavigationTitle() -> String {
        return "Artist Details"
    }
    
    override func loadCards(predicate: NSPredicate?) {
        var cardPredicate:NSPredicate?
        var sorters:[NSSortDescriptor]?
        
        if let artistOID = artistOID {
            if let artist = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(artistOID) as? Artist {
                cardPredicate = NSPredicate(format: "artist == %@", artist)
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



