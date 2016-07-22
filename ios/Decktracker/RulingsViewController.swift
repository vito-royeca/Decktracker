//
//  RulingsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 20/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

class RulingsViewController: UIViewController {

    // MARK: Variables
    var cardOID:NSManagedObjectID?
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
                    let sectionNameKeyPath = "yearKeyPath"
                    let sorters = [NSSortDescriptor(key: "date", ascending: false)]
                    
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
        let sectionNameKeyPath = "yearKeyPath"
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest!,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: sectionNameKeyPath,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
    var formatter:NSDateFormatter?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Rulings"
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        formatter = NSDateFormatter()
        formatter!.dateFormat = "YYYY-MM-dd"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadRulings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Custom methods
    func loadRulings() {
        let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
        let predicate = NSPredicate(format: "card.cardID == %@", card.cardID!)
        let sorters = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchRequest = NSFetchRequest(entityName: "Ruling")
        fetchRequest!.predicate = predicate
        fetchRequest!.sortDescriptors = sorters
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
        
        tableView.reloadData()
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            let sectionInfo = sections[indexPath.section]
            
            if let objects = sectionInfo.objects {
                if let ruling = objects[indexPath.row] as? Ruling,
                    let c = cell as? DynamicHeightTableViewCell {
                    
                    c.dynamicLabel.text = "\(formatter!.stringFromDate(ruling.date!))\n\n\(ruling.text!)"
                }
            }
        }
    }
    
    func dynamicHeightForCell(identifier: String, indexPath: NSIndexPath) -> CGFloat {
        if let cell = tableView.dequeueReusableCellWithIdentifier(identifier) {
            configureCell(cell, indexPath: indexPath)
            cell.layoutIfNeeded()
            let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize)
            return size.height + (size.height/4)
        } else {
            return UITableViewAutomaticDimension
        }
    }
}

// MARK: UITableViewDataSource
extension RulingsViewController: UITableViewDataSource {
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

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if fetchRequest != nil,
            let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            var count = 0
            if let objects = sectionInfo.objects {
                count = objects.count
            }
            
            return "\(sectionInfo.name) (\(count) \(count > 1 ? "items" : "item"))"
            
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
extension RulingsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dynamicHeightForCell("Cell", indexPath: indexPath)
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension RulingsViewController : NSFetchedResultsControllerDelegate {
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
