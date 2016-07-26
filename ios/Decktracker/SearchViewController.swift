//
//  SearchViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD
import MMDrawerController

class SearchViewController: CardListViewController {

    // MARK: Variables
    
    
    
    // MARK: Outlets
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    // MARK: Actions
    
    @IBAction func settingsAction(sender: UIBarButtonItem) {
        mm_drawerController.toggleDrawerSide(.Right, animated:true, completion:nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = settingsButton
        navigationItem.titleView = searchBar
        
        mm_drawerController.showsShadow = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"kCloseOpenDrawersNotif",  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SearchViewController.closeDrawers), name: "kCloseOpenDrawersNotif", object:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Custom methods
    func closeDrawers() {
        mm_drawerController.closeDrawerAnimated(false, completion:nil)
    }
    
    override func loadCards(predicate: NSPredicate?) {
        var sorters:[NSSortDescriptor]?
        
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
        fetchRequest!.predicate = predicate
        fetchRequest!.sortDescriptors = sorters
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
    }
    
    func doSearch() {
        var predicate:NSPredicate?
        
        if let text = searchBar.text {
            if text.characters.count > 0 {
                
                // if only 1 letter, search beginning letter else search containg letters
                if text.characters.count == 1 {
                    predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", text)
                } else {
                    predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
                }
            }
        }
        
        loadCards(predicate)
        tableView.reloadData()
    }
    
    // MARK: CardlistViewController
    override func hasWiki() -> Bool {
        return false
    }
}

// MARK: UISearchBarDelegate
extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let address = searchBar.text {
            if address.isEmpty {
                return
            }
            
            searchBar.resignFirstResponder()
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            doSearch()
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
}
