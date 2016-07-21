//
//  ArtistViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 20/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

class ArtistViewController: UIViewController {

    // MARK: Variables
    var artistOID:NSManagedObjectID?
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
                    
                    switch NSUserDefaults.standardUserDefaults().integerForKey("artistSortMode") {
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
        
        switch NSUserDefaults.standardUserDefaults().integerForKey("artistSortMode") {
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
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UITableViewDataSource
extension ArtistViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if fetchRequest != nil,
//            let sections = fetchedResultsController.sections {
//            let sectionInfo = sections[section]
//            return sectionInfo.numberOfObjects
//            
//        } else {
            return 0
//        }
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if fetchRequest != nil,
//            let sections = fetchedResultsController.sections {
//            return sections.count
//            
//        } else {
//            return 0
//        }
//    }
//    
//    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
//        if fetchRequest != nil,
//            let sections = fetchedResultsController.sections {
//            
//            switch sortMode! {
//            case .ByName:
//                var indexTitles = [String]()
//                
//                for sectionInfo in sections {
//                    if let indexTitle = sectionInfo.indexTitle {
//                        if !indexTitles.contains(indexTitle) {
//                            indexTitles.append(indexTitle)
//                        }
//                    }
//                }
//                return indexTitles
//                
//            default:
//                return nil
//            }
//            
//        } else {
//            return nil
//        }
//    }
//    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if fetchRequest != nil,
//            let sections = fetchedResultsController.sections {
//            let sectionInfo = sections[section]
//            var count = 0
//            if let objects = sectionInfo.objects {
//                count = objects.count
//            }
//            
//            switch sortMode! {
//            case .ByName:
//                return "\(sectionInfo.indexTitle!) (\(count) \(count > 1 ? "items" : "item"))"
//            default:
//                return "\(sectionInfo.name) (\(count) \(count > 1 ? "items" : "item"))"
//            }
//            
//        } else {
//            return nil
//        }
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
//        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
}

// MARK: UITableVIewDelegate
extension ArtistViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

