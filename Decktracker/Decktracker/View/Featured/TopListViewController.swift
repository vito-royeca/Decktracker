//
//  TopListViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class TopListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let kSearchResultsIdentifier = "kSearchResultsIdentifier"
    
    var tblList:UITableView?
    var arrayData:[AnyObject]?
    var sections:[String: [Set]]?
    var sectionIndexTitles:[String]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        let frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        tblList = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblList!.registerNib(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: kSearchResultsIdentifier)
        tblList!.delegate = self
        tblList!.dataSource = self
        
        view.addSubview(tblList!)
        loadData()
        
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: self.navigationItem.title)
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        if navigationItem.title == "Top Rated"  || navigationItem.title == "Top Viewed" {
            NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector:"updateData:",  name:kFetchTopRatedDone, object:nil)
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector:"updateData:",  name:kFetchTopViewedDone, object:nil)
        
        } else if navigationItem.title == "Sets" {
            sections = [String: [Set]]()
            sectionIndexTitles = [String]()
            
            for setType in SetType.MR_findAllSortedBy("name", ascending: true) as [SetType] {
                for set in arrayData! as [Set] {
                    if set.type == setType {
                        let keys = Array(sections!.keys)
                        var sets:[Set]?
                        
                        if contains(keys, setType.name) {
                            sets = sections![setType.name]
                        } else {
                            sets = [Set]()
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
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
    }
    
    // UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if navigationItem.title == "Sets" {
            return UITableViewAutomaticDimension
        } else {
            return CGFloat(SEARCH_RESULTS_CELL_HEIGHT)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if navigationItem.title == "Top Rated" || navigationItem.title == "Top Viewed"{
            return arrayData!.count
            
        } else if navigationItem.title == "Sets" {
            let keys = Array(sections!.keys).sorted(<)
            let key = keys[section]
            let sets = sections![key]
            return sets!.count
            
        } else {
            return arrayData!.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if navigationItem.title == "Top Rated" || navigationItem.title == "Top Viewed" {
            return 1
            
        } else if navigationItem.title == "Sets" {
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
            return nil
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
            let card = arrayData![indexPath.row] as Card
            
            var cell1 = tableView.dequeueReusableCellWithIdentifier(kSearchResultsIdentifier) as SearchResultsTableViewCell?
            if cell1 == nil {
                cell1 = SearchResultsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kSearchResultsIdentifier)
            }
            
            cell1!.accessoryType = UITableViewCellAccessoryType.None
            cell1!.selectionStyle = UITableViewCellSelectionStyle.None
            cell1!.displayCard(card)
            if navigationItem.title == "Top Rated" || navigationItem.title == "Top Viewed" {
                cell1!.addRank(indexPath.row+1);
            }
            cell = cell1;
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var view:UIViewController?
        var card:Card?
        
        if navigationItem.title == "Sets" {
            let keys = Array(sections!.keys).sorted(<)
            let key = keys[indexPath.section]
            let sets = sections![key]
            let set = sets![indexPath.row]
            let predicate = NSPredicate(format: "%K = %@", "set.name", set.name)
            let data = Card.MR_findAllSortedBy("name", ascending: true, withPredicate: predicate)
            var view2 = TopListViewController()
            
            view2.navigationItem.title = set.name
            view2.arrayData = data
            view = view2
        } else {
            let card = arrayData![indexPath.row] as Card
            let view2 = CardDetailsViewController()
            view2.card = card
            view = view2
        }
        
        self.navigationController?.pushViewController(view!, animated:false)
    }
    
    // UIScrollViewDelegate
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.isKindOfClass(UITableView.classForCoder()) {
            if navigationItem.title == "Top Rated" {
                if arrayData!.count >= 100 {
                    return
                } else {
                    Database.sharedInstance().fetchTopRated(10, skip: Int32(arrayData!.count))
                }
            } else if navigationItem.title == "Top Viewed" {
                if arrayData!.count >= 100 {
                    return
                } else {
                    Database.sharedInstance().fetchTopViewed(10, skip: Int32(arrayData!.count))
                }
            }
        }
    }
    
    func updateData(sender: AnyObject) {
        let notif = sender as NSNotification
        let dict = notif.userInfo as [String: [Card]]
        let cards = dict["data"]!
        var paths = [NSIndexPath]()

        for card in cards {
            if !contains(arrayData! as [Card], card) {
                arrayData!.append(card)
                paths.append(NSIndexPath(forRow: arrayData!.count-1, inSection: 0))
                FileManager.sharedInstance().downloadCropImage(card, immediately:false)
                FileManager.sharedInstance().downloadCardImage(card, immediately:false)
            }
        }

        if (paths.count > 0) {
            tblList!.beginUpdates()
            tblList!.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.Automatic)
            tblList!.endUpdates()
        }
    }
}
