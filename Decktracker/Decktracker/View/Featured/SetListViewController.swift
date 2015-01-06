//
//  SetListViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/28/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

enum SortMode: Printable  {
    case ByReleaseDate
    case ByName
    case ByType
    case ByNumber
    case ByPrice
    
    var description : String {
        switch self {
        case ByReleaseDate: return "Release Date"
        case ByName: return "Name"
        case ByType: return "Type"
        case ByNumber: return "Collector Number"
        case ByPrice: return "Price (Median)"
        }
    }
}

class SetListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    let kSearchResultsIdentifier = "kSearchResultsIdentifier"
    
    var sortButton:UIBarButtonItem?
    var tblSets:UITableView?
    var sections:[String: [DTSet]]?
    var sectionIndexTitles:[String]?
    var arrayData:[AnyObject]?
    var predicate:NSPredicate?
    var sorters:[NSSortDescriptor]?
    var sortMode:SortMode?

    lazy var fetchedResultsController: NSFetchedResultsController = {
        var nsfrc = Database.sharedInstance().search(nil, withPredicate:self.predicate, withSortDescriptors: self.sorters, withSectionName:nil)
        
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
        
        tblSets = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblSets!.delegate = self
        tblSets!.dataSource = self
        tblSets!.registerNib(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: kSearchResultsIdentifier)

        navigationItem.rightBarButtonItem = sortButton
        view.addSubview(tblSets!)
        
        self.sortMode = SortMode.ByReleaseDate
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
        var initialSelection = 0
        
        if navigationItem.title == "Sets" {
            sortOptions = [SortMode.ByReleaseDate.description, SortMode.ByName.description, SortMode.ByType.description]
            
            switch self.sortMode! {
            case .ByReleaseDate:
                initialSelection = 0
            case .ByName:
                initialSelection = 1
            case .ByType:
                initialSelection = 2
            default:
                break
            }
            
        } else {
            sortOptions = [SortMode.ByName.description, SortMode.ByNumber.description, SortMode.ByPrice.description]
            
            switch self.sortMode! {
            case .ByName:
                initialSelection = 0
            case .ByNumber:
                initialSelection = 1
            case .ByPrice:
                initialSelection = 2
            default:
                break
            }
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            
            if self.navigationItem.title == "Sets" {
                switch selectedIndex {
                case 0:
                    self.sortMode = .ByReleaseDate
                case 1:
                    self.sortMode = .ByName
                case 2:
                    self.sortMode = .ByType
                default:
                    break
                }
                
            } else {
                switch selectedIndex {
                case 0:
                    self.sortMode = .ByName
                case 1:
                    self.sortMode = .ByNumber
                case 2:
                    self.sortMode = .ByPrice
                default:
                    break
                }
            }
            
            self.loadData()
            self.tblSets!.reloadData()
        }
        
        ActionSheetStringPicker.showPickerWithTitle("Sort By",
            rows: sortOptions,
            initialSelection: initialSelection,
            doneBlock: doneBlock,
            cancelBlock: nil,
            origin: view)
    }
    
    func loadData() {
        if self.navigationItem.title == "Sets" {
            sections = [String: [DTSet]]()
            sectionIndexTitles = [String]()
            
            switch sortMode! {
            case .ByReleaseDate:
                arrayData!.sort({ ($0.releaseDate as NSDate).compare($1.releaseDate as NSDate) == NSComparisonResult.OrderedDescending })
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy"
                
                for set in arrayData! as [DTSet] {
                    let keys = Array(sections!.keys)
                    var sets:[DTSet]?
                    
                    let year = formatter.stringFromDate(set.releaseDate)
                    
                    if contains(keys, year) {
                        sets = sections![year]
                    } else {
                        sets = [DTSet]()
                    }
                    sets!.append(set)
                    sections!.updateValue(sets!, forKey: year)
                }
                
            case .ByName:
                arrayData!.sort{ $0.name < $1.name }
                
                for set in arrayData! as [DTSet] {
                    let keys = Array(sections!.keys)
                    var sets:[DTSet]?
                    
                    var letter = set.name.substringWithRange(Range(start: set.name.startIndex, end: advance(set.name.startIndex, 1)))
                    let formatter = NSNumberFormatter()
                    if formatter.numberFromString(letter) != nil {
                        letter = "#"
                    }
                    if !contains(sectionIndexTitles!, letter) {
                        sectionIndexTitles!.append(letter)
                    }
                    
                    if contains(keys, letter) {
                        sets = sections![letter]
                    } else {
                        sets = [DTSet]()
                    }
                    sets!.append(set)
                    sections!.updateValue(sets!, forKey: letter)
                }
                
            case .ByType:
                arrayData!.sort{ $0.name < $1.name }
                
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
        
        } else {
            switch sortMode! {
            case .ByName:
                sorters = [NSSortDescriptor(key: "name", ascending: true)]

            case .ByNumber:
                sorters = [NSSortDescriptor(key: "number", ascending: true)]
                
            case .ByPrice:
                sorters = [NSSortDescriptor(key: "tcgPlayerMidPrice", ascending: false)]
            default:
                break
            }
            
            var nsfrc = Database.sharedInstance().search(nil, withPredicate:self.predicate, withSortDescriptors: sorters, withSectionName:nil)
            self.fetchedResultsController = nsfrc
            self.fetchedResultsController.delegate = self
            self.doSearch()
        }
    }

    func doSearch() {
        var error:NSError?;
        if (!fetchedResultsController.performFetch(&error)) {
            println("Unresolved error \(error), \(error?.userInfo)");
        }

        if tblSets != nil {
            tblSets!.reloadData()
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
            var keys:[String]?
            
            switch self.sortMode! {
            case .ByReleaseDate:
                keys = Array(sections!.keys).sorted(>)
            case .ByName:
                keys = Array(sections!.keys).sorted(<)
            case .ByType:
                keys = Array(sections!.keys).sorted(<)
            default:
                break
            }
            
            let key = keys![section]
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
            var keys:[String]?
            
            switch self.sortMode! {
            case .ByReleaseDate:
                keys = Array(sections!.keys).sorted(>)
            case .ByName:
                keys = Array(sections!.keys).sorted(<)
            case .ByType:
                keys = Array(sections!.keys).sorted(<)
            default:
                break
            }
            
            let key = keys![section]
            let sets = sections![key]
            let setsString = sets!.count > 1 ? "sets" : "set"
            return "\(key) (\(sets!.count) \(setsString))"
            
        } else {
            let sectionInfos = fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
            let sectionInfo = sectionInfos![section]
            let cardsString = sectionInfo.numberOfObjects > 1 ? "cards" : "card"
            return "\(sectionInfo.numberOfObjects) \(cardsString)"
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if navigationItem.title == "Sets" {
            var keys:[String]?
            
            switch self.sortMode! {
            case .ByReleaseDate:
                keys = Array(sections!.keys).sorted(>)
            case .ByName:
                keys = Array(sections!.keys).sorted(<)
            case .ByType:
                keys = Array(sections!.keys).sorted(<)
            default:
                break
            }
            
            let key = keys![indexPath.section]
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
            
            
            let path = FileManager.sharedInstance().setPath(set, small: true)
            
            if path != nil && NSFileManager.defaultManager().fileExistsAtPath(path) {
                let setImage = UIImage(contentsOfFile: path)
                
                cell1!.imageView.image = setImage;
                
                // resize the image
                let itemSize = CGSizeMake(setImage!.size.width/2, setImage!.size.height/2)
                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale)
                let imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height)
                setImage!.drawInRect(imageRect)
                cell1!.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

            } else {
                cell1!.imageView.image = UIImage(named: "blank.png")
            }
            
            cell = cell1
            
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
            var keys:[String]?
            
            switch self.sortMode! {
            case .ByReleaseDate:
                keys = Array(sections!.keys).sorted(>)
            case .ByName:
                keys = Array(sections!.keys).sorted(<)
            case .ByType:
                keys = Array(sections!.keys).sorted(<)
            default:
                break
            }
            let key = keys![indexPath.section]
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
            view2.fetchedResultsController = fetchedResultsController
            view2.card = card
            view = view2
        }
        
        self.navigationController?.pushViewController(view!, animated:false)
    }
    
    // NSFetchedResultsControllerDelegate
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
        
        let tableView = tblSets;
        var paths = [NSIndexPath]()
        
        switch(type) {
        case NSFetchedResultsChangeType.Insert:
            paths.append(newIndexPath!)
            tblSets!.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)

        case NSFetchedResultsChangeType.Delete:
            paths.append(indexPath!)
            tblSets!.deleteRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
            
        case NSFetchedResultsChangeType.Update:
            let card = fetchedResultsController.objectAtIndexPath(indexPath!) as DTCard
            let cell = tblSets!.cellForRowAtIndexPath(indexPath!) as SearchResultsTableViewCell?
            cell?.displayCard(card)
        case NSFetchedResultsChangeType.Move:
            paths.append(indexPath!)
            tblSets!.deleteRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
            
            paths = [NSIndexPath]()
            paths.append(newIndexPath!)
            tblSets!.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
        
        switch(type) {
        case NSFetchedResultsChangeType.Insert:
            tblSets!.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation:UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeType.Delete:
            tblSets!.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation:UITableViewRowAnimation.Fade)
        default:
            break;
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tblSets!.beginUpdates()
//        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        println("\(__LINE__) \(__PRETTY_FUNCTION__) \(__FUNCTION__)")        
        tblSets!.endUpdates()
    }
}
