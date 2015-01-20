//
//  TopListViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class TopListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, InAppPurchaseViewControllerDelegate {

    let kSearchResultsIdentifier = "kSearchResultsIdentifier"
    
    var tblList:UITableView?
    var arrayData:[DTCard]?

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
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"updateData:",  name:kFetchTopRatedDone, object:nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"updateData:",  name:kFetchTopViewedDone, object:nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
    }
    
    // UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(SEARCH_RESULTS_CELL_HEIGHT)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData!.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let card = arrayData![indexPath.row] as DTCard
        
        var cell = tableView.dequeueReusableCellWithIdentifier(kSearchResultsIdentifier) as SearchResultsTableViewCell?
        if cell == nil {
            cell = SearchResultsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kSearchResultsIdentifier)
        }
        
        cell!.accessoryType = UITableViewCellAccessoryType.None
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.displayCard(card)
        cell!.addRank(indexPath.row+1);
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let card = arrayData![indexPath.row] as DTCard
        let dict = Database.sharedInstance().inAppSettingsForSet(card.set)
        var view:UIViewController?
        
        if dict != nil {
            let view2 = InAppPurchaseViewController()
            
            view2.productID = dict["In-App Product ID"] as String
            view2.delegate = self;
            view2.productDetails = ["name" : dict["In-App Display Name"] as String,
                "description": dict["In-App Description"] as String]
            view = view2
            
        } else {
            let view2 = CardDetailsViewController()
            view2.addButtonVisible = true
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
        let dict = notif.userInfo as [String: [DTCard]]
        let cards = dict["data"]!
        var paths = [NSIndexPath]()

        for card in cards {
            if !contains(arrayData! as [DTCard], card) {
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
    
    // InAppPurchaseViewControllerDelegate
    func productPurchaseSucceeded(productID: String)
    {
        Database.sharedInstance().loadInAppSets()
        tblList!.reloadData()
    }
}
