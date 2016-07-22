//
//  SetsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import ActionSheetPicker

enum SetSortMode: CustomStringConvertible  {
    case ByReleaseDate
    case ByName
    case ByType
    
    var description : String {
        switch self {
        case ByReleaseDate: return "Release Date"
        case ByName: return "Name"
        case ByType: return "Type"
        }
    }
}

class SetsViewController: UIViewController {

    // MARK: Variables
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
                    
                    switch NSUserDefaults.standardUserDefaults().integerForKey("setSortMode") {
                    case 0:
                        sectionNameKeyPath = "yearKeyPath"
                        sorters = [NSSortDescriptor(key: "releaseDate", ascending: false)]
                    case 1:
                        sectionNameKeyPath = "nameKeyPath"
                        sorters = [NSSortDescriptor(key: "name", ascending: true)]
                    case 2:
                        sectionNameKeyPath = "typeKeyPath"
                        sorters = [NSSortDescriptor(key: "type.name", ascending: true)]
                    default:
                        sectionNameKeyPath = "yearKeyPath"
                        sorters = [NSSortDescriptor(key: "releaseDate", ascending: false)]
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
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("setSortMode") {
        case 0:
            sectionNameKeyPath = "yearKeyPath"
        case 1:
            sectionNameKeyPath = "nameKeyPath"
        case 2:
            sectionNameKeyPath = "typeKeyPath"
        default:
            sectionNameKeyPath = "yearKeyPath"
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest!,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: sectionNameKeyPath,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
    var formatter:NSDateFormatter?
    var sortMode:SetSortMode?
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Outlets
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func sortAction(sender: UIBarButtonItem) {
        let sortOptions = [SetSortMode.ByReleaseDate.description,
                           SetSortMode.ByName.description,
                           SetSortMode.ByType.description]
        var initialSelection = 0
        
        switch sortMode! {
        case .ByReleaseDate:
            initialSelection = 0
        case .ByName:
            initialSelection = 1
        case .ByType:
            initialSelection = 2
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            switch selectedIndex {
            case 0:
                self.sortMode = .ByReleaseDate
            case 1:
                self.sortMode = .ByName
            case 2:
                self.sortMode = .ByType
            default:
                ()
            }
            
            NSUserDefaults.standardUserDefaults().setInteger(selectedIndex, forKey: "setSortMode")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.loadSets(nil)
        }
        
        var originView:AnyObject?
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            originView = view
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            originView = sender
        }
        
        ActionSheetStringPicker.showPickerWithTitle("Sort By",
                                                    rows: sortOptions,
                                                    initialSelection: initialSelection,
                                                    doneBlock: doneBlock,
                                                    cancelBlock: nil,
                                                    origin: originView)
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
        
        formatter = NSDateFormatter()
        formatter!.dateFormat = "YYYY-MM-dd"
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("setSortMode") {
        case 0:
            sortMode = .ByReleaseDate
        case 1:
            sortMode = .ByName
        case 2:
            sortMode = .ByType
        default:
            sortMode = .ByReleaseDate
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadSets(nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSetDetails" {
            
            if let indexPath = tableView.indexPathForSelectedRow,
                let _ = fetchRequest {
                
                let sections = fetchedResultsController.sections
                let sectionInfo = sections![indexPath.section]
                
                if let objects = sectionInfo.objects {
                    if let set = objects[indexPath.row] as? Set,
                        let detailsVC = segue.destinationViewController as? SetDetailsViewController {
                        detailsVC.setOID = set.objectID
                    }
                }
            }
        }
    }
    
    // MARK: Custom methods
    func loadSets(predicate: NSPredicate?) {
        var sorters:[NSSortDescriptor]?
        
        switch sortMode! {
        case .ByReleaseDate:
            sorters = [NSSortDescriptor(key: "releaseDate", ascending: false)]
        case .ByName:
            sorters = [NSSortDescriptor(key: "name", ascending: true)]
        case .ByType:
            sorters = [NSSortDescriptor(key: "type.name", ascending: true)]
        }
        
        fetchRequest = NSFetchRequest(entityName: "Set")
        fetchRequest!.predicate = predicate
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
        
        loadSets(predicate)
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            let sectionInfo = sections[indexPath.section]
            
            if let objects = sectionInfo.objects {
                if let set = objects[indexPath.row] as? Set {
                    if let path = setIconPath(set) {
                        cell.imageView!.image = UIImage(contentsOfFile: path)
                    } else {
                        cell.imageView!.image = UIImage(named: "blank")
                    }
                    cell.textLabel!.text = set.name
                    cell.detailTextLabel!.text = "Released: \(formatter!.stringFromDate(set.releaseDate!)) (\(set.numberOfCards!) card\(set.numberOfCards!.intValue > 1 ? "s": ""))"
                    cell.accessoryType = .DisclosureIndicator
                }
            }
        }
    }

    func setIconPath(set: Set) -> String? {
        let sorter = NSSortDescriptor(key: "symbol", ascending: true)
        
        for r in ObjectManager.sharedInstance.findObjects("Rarity", predicate: nil, sorters: [sorter]) {
            if let rarity = r as? Rarity {
                let path = "\(NSBundle.mainBundle().bundlePath)/images/set/\(set.code!)/\(rarity.symbol!)/32.png"
                
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    return path
                }
            }
        }
        
        return nil
    }

}

// MARK: UITableViewDataSource
extension SetsViewController: UITableViewDataSource {
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
            var count = 0
            if let objects = sectionInfo.objects {
                count = objects.count
            }
            
            switch sortMode! {
            case .ByName:
                return "\(sectionInfo.indexTitle!) (\(count) \(count > 1 ? "items" : "item"))"
            default:
                return "\(sectionInfo.name) (\(count) \(count > 1 ? "items" : "item"))"
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
extension SetsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension SetsViewController : NSFetchedResultsControllerDelegate {
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
extension SetsViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        doSearch()
    }
}

// MARK: UISearchBarDelegate
extension SetsViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        NSUserDefaults.standardUserDefaults().setBool(selectedScope == 0 ? false : true, forKey: "favoritesOnly")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        doSearch()
    }
}

