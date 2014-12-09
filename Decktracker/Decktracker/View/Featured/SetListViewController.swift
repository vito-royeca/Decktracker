//
//  SetListViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/28/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

enum SortMode: Printable  {
    case BySetReleaseDate
    case BySetName
    case BySetType
    case ByCardName
    case ByCardNumber
    
    var description : String {
        switch self {
        case BySetReleaseDate: return "By Release Date"
        case BySetName: return "By Name"
        case BySetType: return "By Type"
        case ByCardName: return "By Name"
        case ByCardNumber: return "By Collector Number"
        }
    }
}

class SetListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    let kSearchResultsIdentifier = "kSearchResultsIdentifier"
    
    var sortButton:UIBarButtonItem?
    var tblSet:UITableView?
    var sections:[String: [DTSet]]?
    var sectionIndexTitles:[String]?
    var arrayData:[AnyObject]?
    var predicate:NSPredicate?
    var sortMode:SortMode?

    lazy var fetchedResultsController: NSFetchedResultsController = {
        var nsfrc = Database.sharedInstance().search(nil, withPredicate:self.predicate)
        
        self.fetchedResultsController = nsfrc
        self.fetchedResultsController.delegate = self
        return self.fetchedResultsController
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        
        sortButton = UIBarButtonItem(title: "Sort", style: UIBarButtonItemStyle.Plain, target: self, action: "sortButtonTapped")
        
        tblSet = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblSet!.delegate = self
        tblSet!.dataSource = self
        tblSet!.registerNib(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: kSearchResultsIdentifier)

        navigationItem.rightBarButtonItem = sortButton
        view.addSubview(tblSet!)
        
        self.sortMode = SortMode.BySetReleaseDate
        self.loadData()

#if !DEBUG
    // send the screen to Google Analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Sets")
    tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }
    
    func sortButtonTapped() {
        var sortOptions:[String]?
//        typealias DoneBlock = NSString? -> ()
//        var doneBlock: DoneBlock = { reason in println(reason) }
//        
//        ActionSheetStringPicker.showPickerWithTitle("Sort By",
//            rows:sortOptions,  initialSelection:0,
//            doneBlock:{ (picker: ActionSheetStringPicker, selectedIndex: NSInteger, selectedValue: AnyObject) in
//            
//            },
//            cancelBlock:{ (picker: ActionSheetStringPicker) in
//            
//            },
//            origin:self.view)
        
//        ActionSheetStringPicker.showPickerWithTitle("Sort By", rows: sortOptions, initialSelection: 1, doneBlock: {ActionStringDoneBlock in return}, cancelBlock: {ActionStringCancelBlock in return }, origin: view)
        
    }
    
    func loadData() {
        if self.navigationItem.title == "Sets" {
            sections = [String: [DTSet]]()
            sectionIndexTitles = [String]()
            
            switch sortMode! {
            case .BySetReleaseDate:
                println("")
                
            case .BySetName:
                println("")
                
            case .BySetType:
                for setType in DTSetType.MR_findAllSortedBy("name", ascending: true) as [DTSetType] {
                    for set in arrayData! as [DTSet] {
                        if set.type == setType {
                            let keys = Array(sections!.keys)
                            var sets:[DTSet]?
                            
                            if contains(keys, setType.name) {
                                sets = sections![setType.name]
                            } else {
                                sets = [DTSet]()
                            }
                            sets!.append(set)
                            sections!.updateValue(sets!, forKey: setType.name)
                            
                            let letter = setType.name.substringWithRange(Range(start: setType.name.startIndex, end: advance(setType.name.startIndex, 1)))
                            if !contains(sectionIndexTitles!, letter) {
                                sectionIndexTitles!.append(letter)
                            }
                        }
                    }
                }
                
            default:
                break
            }
        }
    }

    func doSearch() {
        var error:NSError?;
        if (!fetchedResultsController.performFetch(&error)) {
            println("Unresolved error \(error), \(error?.userInfo)");
        }

        if tblSet != nil {
            tblSet!.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if navigationItem.title == "Sets" {
            return UITableViewAutomaticDimension
        } else {
            return CGFloat(SEARCH_RESULTS_CELL_HEIGHT)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.navigationItem.title == "Sets" {
            
            switch sortMode! {
            case .BySetReleaseDate:
                println("")
                
            case .BySetName:
                println("")
                
            case .BySetType:
                println("")
                
            default:
                break
            }
            
            let keys = Array(sections!.keys).sorted(<)
            let key = keys[section]
            let sets = sections![key]
            return sets!.count
            
        } else {
            let sectionInfos = fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
            let sectionInfo = sectionInfos![section]
            return sectionInfo.numberOfObjects
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if navigationItem.title == "Sets" {
            return sections!.count
        } else {
            return 1
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        if navigationItem.title == "Sets" {
            return sectionIndexTitles
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if navigationItem.title == "Sets" {
            let keys = Array(sections!.keys).sorted(<)
            let key = keys[section]
            return key
            
        } else {
            let sectionInfos = fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
            let sectionInfo = sectionInfos![section]
            return "Cards: \(sectionInfo.numberOfObjects)"
        }
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var section = -1
        
        if navigationItem.title == "Sets" {
            let keys = Array(sections!.keys).sorted(<)
            
            for (i, value) in enumerate(keys) {
                if value.hasPrefix(title) {
                    section = i
                    break
                }
            }
        }
        
        return section
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell?
        
        if navigationItem.title == "Sets" {
            let keys = Array(sections!.keys).sorted(<)
            let key = keys[indexPath.section]
            let sets = sections![key]
            let set = sets![indexPath.row]
            let date = JJJUtil.formatDate(set.releaseDate, withFormat:"YYYY-MM-dd")
            
            var cell1 = tableView.dequeueReusableCellWithIdentifier("Default") as UITableViewCell?
            if cell1 == nil {
                cell1 = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Default")
            }
            
            cell1!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell1!.selectionStyle = UITableViewCellSelectionStyle.None
            cell1!.textLabel.text = set.name
            cell1!.detailTextLabel?.text = "Released: \(date) (\(set.numberOfCards) cards)"
            
            
            let path = "\(NSBundle.mainBundle().bundlePath)/images/set/\(set.code)/C/48.png"
            
            if !NSFileManager.defaultManager().fileExistsAtPath(path) {
                cell1!.imageView.image = UIImage(named: "blank.png")
            } else {
                let setImage = UIImage(contentsOfFile: path)
                
                cell1!.imageView.image = setImage;
                
                // resize the image
                let itemSize = CGSizeMake(setImage!.size.width/2, setImage!.size.height/2)
                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale)
                let imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height)
                setImage!.drawInRect(imageRect)
                cell1!.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            
            cell = cell1;
            
        } else {
            
            let card = fetchedResultsController.objectAtIndexPath(indexPath) as DTCard
            
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
        var view:UIViewController?
        var card:DTCard?
        
        if navigationItem.title == "Sets" {
            let keys = Array(sections!.keys).sorted(<)
            let key = keys[indexPath.section]
            let sets = sections![key]
            let set = sets![indexPath.row]
            var view2 = SetListViewController()
            
            view2.navigationItem.title = set.name
            view2.predicate =  NSPredicate(format: "%K = %@", "set.name", set.name)
            view2.doSearch()
            view = view2
            
        } else {
            let card = fetchedResultsController.objectAtIndexPath(indexPath) as DTCard
            let view2 = CardDetailsViewController()
            
            view2.addButtonVisible = true
            view2.card = card
            view2.fetchedResultsController = fetchedResultsController
            view = view2
        }
        
        self.navigationController?.pushViewController(view!, animated:false)
    }
    
    // NSFetchedResultsControllerDelegate
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
        
        let tableView = tblSet;
        var paths = [NSIndexPath]()
        
        switch(type) {
        case NSFetchedResultsChangeType.Insert:
            paths.append(newIndexPath!)
            tblSet!.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)

        case NSFetchedResultsChangeType.Delete:
            paths.append(indexPath!)
            tblSet!.deleteRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
            
        case NSFetchedResultsChangeType.Update:
            let card = fetchedResultsController.objectAtIndexPath(indexPath!) as DTCard
            let cell = tblSet!.cellForRowAtIndexPath(indexPath!) as SearchResultsTableViewCell?
            cell!.displayCard(card)
        case NSFetchedResultsChangeType.Move:
            paths.append(indexPath!)
            tblSet!.deleteRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
            
            paths = [NSIndexPath]()
            paths.append(newIndexPath!)
            tblSet!.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
        
        switch(type) {
        case NSFetchedResultsChangeType.Insert:
            tblSet!.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation:UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeType.Delete:
            tblSet!.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation:UITableViewRowAnimation.Fade)
        default:
            break;
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tblSet!.beginUpdates()
//        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")        
        tblSet!.endUpdates()
    }
}
