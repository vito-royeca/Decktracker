//
//  SetListViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/28/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

enum SetSortMode: Printable  {
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

class SetListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, InAppPurchaseViewControllerDelegate {

    var sortButton:UIBarButtonItem?
//    var segmentedControl:UISegmentedControl?
    var tblSets:UITableView?
//    var webView:UIWebView?
    var sections:[String: [AnyObject]]?
    var sectionIndexTitles:[String]?
    var arrayData:[AnyObject]?
    var predicate:NSPredicate?
    var sorters:[NSSortDescriptor]?
    var sortMode:SetSortMode?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hidesBottomBarWhenPushed = true
        
        let height = view.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        
        sortButton = UIBarButtonItem(image: UIImage(named: "generic_sorting.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "sortButtonTapped")
        
        tblSets = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblSets!.delegate = self
        tblSets!.dataSource = self

        navigationItem.rightBarButtonItem = sortButton
        view.addSubview(tblSets!)
        
        self.sortMode = SetSortMode.ByReleaseDate
        self.loadData()
        
#if !DEBUG
        // send the screen to Google Analytics
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: "Sets")
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
#endif
    }
    
    func sortButtonTapped() {
        var sortOptions:[String]?
        var initialSelection = 0
        
        sortOptions = [SetSortMode.ByReleaseDate.description, SetSortMode.ByName.description, SetSortMode.ByType.description]
        
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
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            
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
        sections = [String: [AnyObject]]()
        sectionIndexTitles = [String]()
        
        switch sortMode! {
        case .ByReleaseDate:
            arrayData!.sort({ ($0.releaseDate as NSDate).compare($1.releaseDate as NSDate) == NSComparisonResult.OrderedDescending })
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy"
            
            for set in arrayData! as! [DTSet] {
                let keys = Array(sections!.keys)
                var sets:[DTSet]?
                
                let year = formatter.stringFromDate(set.releaseDate)
                
                if contains(keys, year) {
                    sets = sections![year] as? [DTSet]
                } else {
                    sets = [DTSet]()
                }
                sets!.append(set)
                sections!.updateValue(sets!, forKey: year)
            }
            
        case .ByName:
            arrayData!.sort{ $0.name < $1.name }
            
            for set in arrayData! as! [DTSet] {
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
                    sets = sections![letter] as? [DTSet]
                } else {
                    sets = [DTSet]()
                }
                sets!.append(set)
                sections!.updateValue(sets!, forKey: letter)
            }
            
        case .ByType:
            arrayData!.sort{ $0.name < $1.name }
            
            for setType in DTSetType.allObjects().sortedResultsUsingProperty("name", ascending: true) {
                let st = setType as! DTSetType
                
                for set in arrayData! as! [DTSet] {
                    if set.type.name == st.name {
                        let keys = Array(sections!.keys)
                        var sets:[DTSet]?
                        
                        if contains(keys, st.name) {
                            sets = sections![st.name] as? [DTSet]
                        } else {
                            sets = [DTSet]()
                        }
                        sets!.append(set)
                        sections!.updateValue(sets!, forKey: st.name)
                        
                        let letter = st.name.substringWithRange(Range(start: st.name.startIndex, end: advance(st.name.startIndex, 1)))
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    MARK: UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return sectionIndexTitles
    }

    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var section = -1
        
        let keys = Array(sections!.keys).sorted(<)
        
        for (i, value) in enumerate(keys) {
            if value.hasPrefix(title) {
                section = i
                break
            }
        }
        
        return section
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Default") as! UITableViewCell?
        
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
        let set = sets![indexPath.row] as! DTSet
        let date = JJJUtil.formatDate(set.releaseDate, withFormat:"YYYY-MM-dd")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Default")
        }
        
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.textLabel!.text = set.name
        cell!.detailTextLabel?.text = "Released: \(date) (\(set.numberOfCards) cards)"
        
        let dict = Database.sharedInstance().inAppSettingsForSet(set.setId)
        
        if dict != nil {
            cell!.imageView!.image = UIImage(named: "locked.png")

        } else {
            let path = FileManager.sharedInstance().setPath(set.setId, small: true)
            
            if path != nil && NSFileManager.defaultManager().fileExistsAtPath(path) {
                let setImage = UIImage(contentsOfFile: path)
                
                cell!.imageView!.image = setImage
                
                // resize the image
                let itemSize = CGSizeMake(setImage!.size.width/2, setImage!.size.height/2)
                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale)
                let imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height)
                setImage!.drawInRect(imageRect)
                cell!.imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
            } else {
                cell!.imageView!.image = UIImage(named: "blank.png")
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var view:UIViewController?
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
        let sets = sections![key] as? [DTSet]
        let set = sets![indexPath.row]
        let dict = Database.sharedInstance().inAppSettingsForSet(set.setId)
        
        if dict != nil {
            let view2 = InAppPurchaseViewController()
            
            view2.productID = dict["In-App Product ID"] as! String
            view2.delegate = self
            view2.productDetails = ["name" : dict["In-App Display Name"] as! String,
                                    "description": dict["In-App Description"] as! String]
            view = view2

        } else {
            let view2 = CardListViewController()
            view2.navigationItem.title = set.name
            view2.predicate =  NSPredicate(format: "%K = %@", "set.name", set.name)
            view = view2
        }
        
        self.navigationController?.pushViewController(view!, animated:false)
    }
    
//    MARK: InAppPurchaseViewControllerDelegate
    func productPurchaseCancelled() {
        // empty implementation
    }
    
    func productPurchaseSucceeded(productID: String)
    {
        Database.sharedInstance().loadInAppSets()
        tblSets!.reloadData()
    }
}
