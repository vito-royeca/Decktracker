//
//  LegalitiesViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 20/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

class LegalitiesViewController: UIViewController {

    // MARK: Variables
    var cardOID:NSManagedObjectID?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Legalities"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: UITableViewDataSource
extension LegalitiesViewController: UITableViewDataSource {
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
extension LegalitiesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
