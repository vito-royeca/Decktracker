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

enum SetDetailsDisplayMode: CustomStringConvertible  {
    case List
    case TwoByTwo
    case ThreeByThree
    
    var description : String {
        switch self {
        case List: return "List"
        case TwoByTwo: return "2x2"
        case ThreeByThree: return "3x3"
        }
    }
}


enum SetDetailsSortMode: CustomStringConvertible  {
    case ByName
    case ByColor
    case ByType
    case ByRarity
    
    var description : String {
        switch self {
        case ByName: return "Name"
        case ByColor: return "Color"
        case ByType: return "Type"
        case ByRarity: return "Rarity"
        }
    }
}

class SetDetailsViewController: UIViewController {

    // MARK: Variables
    var setOID:NSManagedObjectID?
    private var _fetchRequest:NSFetchRequest? = nil
    var fetchRequest:NSFetchRequest? {
        get {
            return _fetchRequest
        }
        set (aNewValue) {
            
            if (_fetchRequest != aNewValue) {
                _fetchRequest = aNewValue
                
                // force reset the fetchedResultsController
                if let _fetchRequest = _fetchRequest {
                    let context = CoreDataManager.sharedInstance.mainObjectContext
                    var sectionNameKeyPath:String?
                    var sorters:[NSSortDescriptor]?
                    
                    switch NSUserDefaults.standardUserDefaults().integerForKey("setDetailsSortMode") {
                    case 0:
                        sectionNameKeyPath = "nameKeyPath"
                        sorters = [NSSortDescriptor(key: "name", ascending: true)]
                    case 1:
                        sectionNameKeyPath = "colorKeyPath"
                        sorters = [NSSortDescriptor(key: "colorSection.name", ascending: true)]
                    case 2:
                        sectionNameKeyPath = "typeKeyPath"
                        sorters = [NSSortDescriptor(key: "type.name", ascending: true)]
                    case 3:
                        sectionNameKeyPath = "rarityKeyPath"
                        sorters = [NSSortDescriptor(key: "rarity.name", ascending: true)]
                    default:
                        sectionNameKeyPath = "nameKeyPath"
                        sorters = [NSSortDescriptor(key: "name", ascending: true)]
                    }
                    
                    _fetchRequest.sortDescriptors = sorters
                    fetchedResultsController = NSFetchedResultsController(fetchRequest: _fetchRequest,
                                                                          managedObjectContext: context,
                                                                          sectionNameKeyPath: sectionNameKeyPath,
                                                                          cacheName: nil)
                }
            }
        }
    }
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let context = CoreDataManager.sharedInstance.mainObjectContext
        var sectionNameKeyPath:String?
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("setDetailsSortMode") {
        case 0:
            sectionNameKeyPath = "nameKeyPath"
        case 1:
            sectionNameKeyPath = "colorKeyPath"
        case 2:
            sectionNameKeyPath = "typeKeyPath"
        case 3:
            sectionNameKeyPath = "rarityKeyPath"
        default:
            sectionNameKeyPath = "nameKeyPath"
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest!,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: sectionNameKeyPath,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
    var displayMode:SetDetailsDisplayMode?
    var sortMode:SetDetailsSortMode?
    let searchController = UISearchController(searchResultsController: nil)

    
    // MARK: Outlets
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet weak var displayButton: UIBarButtonItem!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func segmentedAction(sender: UISegmentedControl) {
        
    }
    
    @IBAction func displayAction(sender: UIBarButtonItem) {
        let displayOptions = [SetDetailsDisplayMode.List.description,
                              SetDetailsDisplayMode.TwoByTwo.description,
                              SetDetailsDisplayMode.ThreeByThree.description]
        var initialSelection = 0
        
        switch displayMode! {
        case .List:
            initialSelection = 0
        case .TwoByTwo:
            initialSelection = 1
        case .ThreeByThree:
            initialSelection = 2
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            switch selectedIndex {
            case 0:
                self.displayMode = .List
                self.displayButton.image = UIImage(named: "list")
            case 1:
                self.displayMode = .TwoByTwo
                self.displayButton.image = UIImage(named: "2x2")
            case 2:
                self.displayMode = .ThreeByThree
                self.displayButton.image = UIImage(named: "3x3")
            default:
                ()
            }
            
            NSUserDefaults.standardUserDefaults().setInteger(selectedIndex, forKey: "setDetailsDisplayMode")
            NSUserDefaults.standardUserDefaults().synchronize()
//            self.loadCards(nil)
        }
        
        ActionSheetStringPicker.showPickerWithTitle("Display As",
                                                    rows: displayOptions,
                                                    initialSelection: initialSelection,
                                                    doneBlock: doneBlock,
                                                    cancelBlock: nil,
                                                    origin: view)
    }
    
    @IBAction func sortAction(sender: UIBarButtonItem) {
        let sortOptions = [SetDetailsSortMode.ByName.description,
                           SetDetailsSortMode.ByColor.description,
                           SetDetailsSortMode.ByType.description,
                           SetDetailsSortMode.ByRarity.description]
        var initialSelection = 0
        
        switch sortMode! {
        case .ByName:
            initialSelection = 0
        case .ByColor:
            initialSelection = 1
        case .ByType:
            initialSelection = 2
        case .ByRarity:
            initialSelection = 3
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            switch selectedIndex {
            case 0:
                self.sortMode = .ByName
            case 1:
                self.sortMode = .ByColor
            case 2:
                self.sortMode = .ByType
            case 3:
                self.sortMode = .ByRarity
            default:
                ()
            }
            
            NSUserDefaults.standardUserDefaults().setInteger(selectedIndex, forKey: "setDetailsSortMode")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.loadCards(nil)
        }
        
        ActionSheetStringPicker.showPickerWithTitle("Sort By",
                                                    rows: sortOptions,
                                                    initialSelection: initialSelection,
                                                    doneBlock: doneBlock,
                                                    cancelBlock: nil,
                                                    origin: view)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.registerNib(UINib(nibName: "CardSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("setDetailsDisplayMode") {
        case 0:
            displayMode = .List
            displayButton.image = UIImage(named: "list")
        case 1:
            displayMode = .TwoByTwo
            displayButton.image = UIImage(named: "2x2")
        case 2:
            displayMode = .ThreeByThree
            displayButton.image = UIImage(named: "3x3")
        default:
            displayMode = .List
        }
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("setDetailsSortMode") {
        case 0:
            sortMode = .ByName
        case 1:
            sortMode = .ByColor
        case 2:
            sortMode = .ByType
        case 3:
            sortMode = .ByRarity
        default:
            sortMode = .ByName
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCards(nil)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showCardDetails" {
//            
//            if let indexPath = tableView.indexPathForSelectedRow,
//                let _ = fetchRequest {
//                
//                let sections = fetchedResultsController.sections
//                let sectionInfo = sections![indexPath.section]
//                
//                if let objects = sectionInfo.objects {
//                    if let card = objects[indexPath.row] as? Card {
//                        
//                        let detailsVC = (segue.destinationViewController as! UINavigationController).topViewController as! CardDetailsViewController
//                        detailsVC.cardOID = card.objectID
//                    }
//                }
//            }
//        }
//    }

    // MARK: Custom methods
    func loadCards(predicate: NSPredicate?) {
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
        
        tableView.reloadData()
    }
    
    func doSearch() {
        var predicate:NSPredicate?
        
        if let text = searchController.searchBar.text {
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
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            let sectionInfo = sections[indexPath.section]
            
            if let objects = sectionInfo.objects {
                if let card = objects[indexPath.row] as? Card {
                    if let c = cell as? CardSummaryTableViewCell {
                        c.cardOID = card.objectID
                    }
                }
            }
        }
    }
}

// MARK: UITableViewDataSource
extension SetDetailsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
            
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            return sections.count
            
        } else {
            return 0
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            switch sortMode! {
            case .ByName:
                var indexTitles = [String]()
                
                for sectionInfo in sections {
                    if let indexTitle = sectionInfo.indexTitle {
                        if !indexTitles.contains(indexTitle) {
                            indexTitles.append(indexTitle)
                        }
                    }
                }
                return indexTitles
            
            default:
                return nil
            }
            
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            
            switch sortMode! {
            case .ByName:
                return sectionInfo.indexTitle
            default:
                return sectionInfo.name
            }
            
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
}

// MARK: UITableVIewDelegate
extension SetDetailsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CardSummaryTableViewCell.CellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier("showCardDetails", sender: indexPath)
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CardDetailsViewController") as? CardDetailsViewController,
            let navigationController = navigationController,
            let _ = fetchRequest {
            
            let sections = fetchedResultsController.sections
            let sectionInfo = sections![indexPath.section]
            
            if let objects = sectionInfo.objects {
                if let card = objects[indexPath.row] as? Card {
                    
                    controller.cardOID = card.objectID
                    navigationController.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension SetDetailsViewController : NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        case .Update:
            tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: newIndexPath!.section)], withRowAnimation: .Automatic)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath!.row, inSection: indexPath!.section)], withRowAnimation: .Automatic)
            
        case .Update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    configureCell(cell, indexPath: indexPath)
                }
            }
            
        case .Move:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}

// MARK: UISearchResultsUpdating
extension SetDetailsViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        doSearch()
    }
}

// MARK: UISearchBarDelegate
extension SetDetailsViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        NSUserDefaults.standardUserDefaults().setBool(selectedScope == 0 ? false : true, forKey: "favoritesOnly")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        doSearch()
    }
}
