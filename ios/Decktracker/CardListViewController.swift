//
//  CardListViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 18/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import ActionSheetPicker

enum CardListDisplayMode: CustomStringConvertible  {
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


enum CardListSortMode: CustomStringConvertible  {
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

class CardListViewController: UIViewController {
    // MARK: Things to override for subclasses
    func hasWiki() -> Bool {
        return false
    }
    func getWikiSegueName() -> String {
        return ""
    }
    func  getWikiURLString() -> String {
        return ""
    }
    func getWikiCellTitle() -> String {
        return ""
    }
    func getWikiNavigationTitle() -> String {
        return ""
    }
    func loadCards(predicate: NSPredicate?) {
        
    }
    
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
                    
                    switch NSUserDefaults.standardUserDefaults().integerForKey("cardListSortMode") {
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
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("cardListSortMode") {
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
    var displayMode:CardListDisplayMode?
    var sortMode:CardListSortMode?
    let searchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: Outlets
    @IBOutlet weak var displayButton: UIBarButtonItem!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func displayAction(sender: UIBarButtonItem) {
        let displayOptions = [CardListDisplayMode.List.description,
                              CardListDisplayMode.TwoByTwo.description,
                              CardListDisplayMode.ThreeByThree.description]
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
            
            NSUserDefaults.standardUserDefaults().setInteger(selectedIndex, forKey: "cardListDisplayMode")
            NSUserDefaults.standardUserDefaults().synchronize()
//            self.loadCards(nil)
//            self.tableView.reloadData()
        }
        
        var originView:AnyObject?
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            originView = view
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            originView = sender
        }
        
        ActionSheetStringPicker.showPickerWithTitle("Display As",
                                                    rows: displayOptions,
                                                    initialSelection: initialSelection,
                                                    doneBlock: doneBlock,
                                                    cancelBlock: nil,
                                                    origin: originView)
    }
    
    @IBAction func sortAction(sender: UIBarButtonItem) {
        let sortOptions = [CardListSortMode.ByName.description,
                           CardListSortMode.ByColor.description,
                           CardListSortMode.ByType.description,
                           CardListSortMode.ByRarity.description]
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
            
            NSUserDefaults.standardUserDefaults().setInteger(selectedIndex, forKey: "cardListSortMode")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.loadCards(nil)
            self.tableView.reloadData()
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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "wikiCell")
        tableView.registerNib(UINib(nibName: "CardSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "summaryCell")
        
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("cardListDisplayMode") {
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
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("cardListSortMode") {
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
        
        loadCards(nil)
        tableView.reloadData()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == getWikiSegueName() {
            if let detailsVC = segue.destinationViewController as? BrowserViewController {
                detailsVC.urlString = getWikiURLString()
                detailsVC.navigationTitle = getWikiNavigationTitle()
            }
            
        } else if segue.identifier == "showCardDetails" {
            
            if let indexPath = tableView.indexPathForSelectedRow,
                let _ = fetchRequest {
                
                let sections = fetchedResultsController.sections
                let sectionOffset = hasWiki() ? 1 : 0
                let sectionInfo = sections![indexPath.section-sectionOffset]
                
                if let objects = sectionInfo.objects {
                    if let card = objects[indexPath.row] as? Card,
                        let detailsVC = segue.destinationViewController as? CardDetailsViewController {
                        detailsVC.cardOID = card.objectID
                        detailsVC.browseFetchRequest = fetchRequest
                    }
                }
            }
        }
    }
    
    // MARK: Custom methods
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        cell.selectionStyle = .Default
        cell.accessoryType = .None
        
        if hasWiki() {
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = getWikiCellTitle()
                cell.accessoryType = .DisclosureIndicator
                cell.imageView?.image = UIImage(named: "Wikipedia")
            default:
                if fetchRequest != nil,
                    let sections = fetchedResultsController.sections,
                    let c = cell as? CardSummaryTableViewCell {
                    let sectionInfo = sections[indexPath.section-1]
                    
                    if let objects = sectionInfo.objects {
                        if let card = objects[indexPath.row] as? Card {
                            c.cardOID = card.objectID
                        }
                    }
                    cell.selectionStyle = .Default
                }
            }
            
        } else {
            if fetchRequest != nil,
                let sections = fetchedResultsController.sections,
                let c = cell as? CardSummaryTableViewCell {
                let sectionInfo = sections[indexPath.section]
                
                if let objects = sectionInfo.objects {
                    if let card = objects[indexPath.row] as? Card {
                        c.cardOID = card.objectID
                    }
                }
                cell.selectionStyle = .Default
            }
        }
    }
}

// MARK: UITableViewDataSource
extension CardListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasWiki() {
            switch section {
            case 0:
                return 1
            default:
                if fetchRequest != nil,
                    let sections = fetchedResultsController.sections {
                    let sectionInfo = sections[section-1]
                    return sectionInfo.numberOfObjects
                    
                } else {
                    return 0
                }
            }
        
        } else {
            if fetchRequest != nil,
                let sections = fetchedResultsController.sections {
                let sectionInfo = sections[section]
                return sectionInfo.numberOfObjects
                
            } else {
                return 0
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            return sections.count + (hasWiki() ? 1 : 0)
            
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
                
                if hasWiki() {
                    indexTitles.append("")
                }
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
        if hasWiki() {
            switch section {
            case 0:
                return nil
            default:
                if fetchRequest != nil,
                    let sections = fetchedResultsController.sections {
                    let sectionInfo = sections[section-1]
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
            
        } else {
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
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if hasWiki() {
            switch indexPath.section {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("wikiCell", forIndexPath: indexPath)
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath)
            }
        
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath)
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

// MARK: UITableVIewDelegate
extension CardListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if hasWiki() {
            switch indexPath.section {
            case 0:
                return UITableViewAutomaticDimension
            default:
                return CardSummaryTableViewCell.CellHeight
            }
            
        } else {
            return CardSummaryTableViewCell.CellHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if hasWiki() {
            switch indexPath.section {
            case 0:
                performSegueWithIdentifier(getWikiSegueName(), sender: indexPath.row)
            default:
                performSegueWithIdentifier("showCardDetails", sender: indexPath.row)
            }
            
        } else {
            performSegueWithIdentifier("showCardDetails", sender: indexPath.row)
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension CardListViewController : NSFetchedResultsControllerDelegate {
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
