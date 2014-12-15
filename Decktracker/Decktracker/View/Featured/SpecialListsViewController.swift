//
//  ListsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/10/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class SpecialListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    let kSearchResultsIdentifier = "kSearchResultsIdentifier"

    var backButton:UIBarButtonItem?
    var filterButton:UIBarButtonItem?
    var tblCards:UITableView?
    var sections:[String: [DTCard]]?
    var sectionIndexTitles:[String]?
    var arrayData:[AnyObject]?
    var predicate:NSPredicate?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        var nsfrc = Database.sharedInstance().search(nil, withPredicate:self.predicate, withSortDescriptors: nil, withSectionName:nil)
        
        self.fetchedResultsController = nsfrc
        self.fetchedResultsController.delegate = self
        return self.fetchedResultsController
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        
        backButton = UIBarButtonItem(image: UIImage(named: "back.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonTapped")
        
        filterButton = UIBarButtonItem(image: UIImage(named: "filter.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "filterButtonTapped")
        
        tblCards = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblCards!.delegate = self
        tblCards!.dataSource = self
        tblCards!.registerNib(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: kSearchResultsIdentifier)
        
        navigationItem.leftBarButtonItem = backButton
        view.addSubview(tblCards!)
        navigationItem.title = "Special Lists"
        
        self.loadData()
        
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Special Lists")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped() {
        if navigationItem.title == "Special Lists" {
            navigationController?.popToRootViewControllerAnimated(false)

        } else {
            navigationItem.title = "Special Lists"
            navigationItem.rightBarButtonItem = nil
            self.loadData()
            tblCards!.reloadData()
        }
    }
    
    func filterButtonTapped() {
        
    }
    
    func loadData() {
        if navigationItem.title == "Special Lists" {
            arrayData = ["Banned and Restricted", "Power Nine", "Reserved"]
        }
    }

    func doSearch() {
        var error:NSError?;
        if (!fetchedResultsController.performFetch(&error)) {
            println("Unresolved error \(error), \(error?.userInfo)");
        }
        
        if tblCards != nil {
            tblCards!.reloadData()
        }
    }
    
    // UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if navigationItem.title == "Special Lists" {
            return UITableViewAutomaticDimension
        } else {
            return CGFloat(SEARCH_RESULTS_CELL_HEIGHT)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if navigationItem.title == "Special Lists" {
            return arrayData!.count

        } else {
            let sectionInfos = fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
            let sectionInfo = sectionInfos![section]
            return sectionInfo.numberOfObjects
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if navigationItem.title == "Special Lists" ||
           navigationItem.title == "Power Nine" {
            return 1
        } else {
            let sectionInfos = fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
            return sectionInfos!.count
        }
    }
    
//    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
//        if navigationItem.title == "Special Lists" ||
//            navigationItem.title == "Power Nine" {
//                return nil
//        } else {
//            var titles = [String]()
//            
//            let sectionInfos = fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
//            for sectionInfo in sectionInfos! {
//                titles.append(sectionInfo.name!.substringWithRange(Range(start: sectionInfo.name!.startIndex, end: advance(sectionInfo.name!.startIndex, 1))))
//            }
//            return titles
//        }
//    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if navigationItem.title == "Special Lists" ||
           navigationItem.title == "Power Nine" {
           return nil
            
        } else {
            let sectionInfos = fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
            let sectionInfo = sectionInfos![section]
            return sectionInfo.name
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if navigationItem.title == "Special Lists" {
            var cell1 = tableView.dequeueReusableCellWithIdentifier("Default") as UITableViewCell?
            if cell1 == nil {
                cell1 = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Default")
            }
            
            cell1?.textLabel.text = arrayData![indexPath.row] as? String
            cell1?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            cell = cell1
        
        } else {
            let sectionInfos = fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
            let sectionInfo = sectionInfos![indexPath.section]
            let card = sectionInfo.objects[indexPath.row] as DTCard
            
//            let card = fetchedResultsController.objectAtIndexPath(indexPath) as DTCard
            
            var cell1 = tableView.dequeueReusableCellWithIdentifier(kSearchResultsIdentifier) as SearchResultsTableViewCell?
            if cell1 == nil {
                cell1 = SearchResultsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kSearchResultsIdentifier)
            }
            
            cell1!.accessoryType = UITableViewCellAccessoryType.None
            cell1!.selectionStyle = UITableViewCellSelectionStyle.None
            cell1!.displayCard(card)
            cell = cell1;
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if navigationItem.title == "Special Lists" {
            let list = arrayData![indexPath.row] as? String
            var sorters:[NSSortDescriptor]?
            var sectionName:String?
            
            if list == "Banned and Restricted" {
                predicate = NSPredicate(format: "ANY legalities.name = 'Banned' OR ANY legalities.name = 'Restricted'")
//                sorters = [NSSortDescriptor(key: "legalities.format.name", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
//                sectionName = "legalities.format.name"
                navigationItem.rightBarButtonItem = filterButton
                
            } else if list == "Power Nine" {
              let names =  ["Black Lotus", "Mox Pearl", "Mox Jet", "Mox Emerald", "Mox Sapphire", "Mox Ruby", "Ancestral Recall", "Time Walk", "Timetwister"]
                
                predicate = NSPredicate(format: "name IN(%@)", names)
            
            } else if list == "Reserved" {
                predicate = NSPredicate(format: "%K = %@", "reserved", NSNumber(bool: true))
                sorters = [NSSortDescriptor(key: "set.name", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
                sectionName = "set.name"
                navigationItem.rightBarButtonItem = filterButton
            }
            
            navigationItem.title = list
            var nsfrc = Database.sharedInstance().search(nil, withPredicate:self.predicate, withSortDescriptors: sorters, withSectionName:sectionName)
            self.fetchedResultsController = nsfrc
            self.fetchedResultsController.delegate = self
            self.doSearch()
            
        } else {
            let card = fetchedResultsController.objectAtIndexPath(indexPath) as DTCard
            let view2 = CardDetailsViewController()
            
            view2.addButtonVisible = true
            view2.fetchedResultsController = fetchedResultsController
            view2.card = card
            self.navigationController?.pushViewController(view2, animated:false)
        }
    }
    
    // NSFetchedResultsControllerDelegate
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        //        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
        
        let tableView = tblCards;
        var paths = [NSIndexPath]()
        
        switch(type) {
        case NSFetchedResultsChangeType.Insert:
            paths.append(newIndexPath!)
            tblCards!.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
            
        case NSFetchedResultsChangeType.Delete:
            paths.append(indexPath!)
            tblCards!.deleteRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
            
        case NSFetchedResultsChangeType.Update:
            let card = fetchedResultsController.objectAtIndexPath(indexPath!) as DTCard
            let cell = tblCards!.cellForRowAtIndexPath(indexPath!) as SearchResultsTableViewCell?
            cell?.displayCard(card)
        case NSFetchedResultsChangeType.Move:
            paths.append(indexPath!)
            tblCards!.deleteRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
            
            paths = [NSIndexPath]()
            paths.append(newIndexPath!)
            tblCards!.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        //        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
        
        switch(type) {
        case NSFetchedResultsChangeType.Insert:
            tblCards!.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation:UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeType.Delete:
            tblCards!.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation:UITableViewRowAnimation.Fade)
        default:
            break;
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tblCards!.beginUpdates()
        //        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        //        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
        tblCards!.endUpdates()
    }
}
