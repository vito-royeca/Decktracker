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
    var arrayData:[Card]?
    
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
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"updateData:",  name:kFetchTopRatedDone, object:nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"updateData:",  name:kFetchTopViewedDone, object:nil)
        
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
    }
    
    // UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(SEARCH_RESULTS_CELL_HEIGHT)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if arrayData != nil {
            return arrayData!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(kSearchResultsIdentifier) as SearchResultsTableViewCell?
        if cell == nil {
            cell = SearchResultsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kSearchResultsIdentifier)
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        if arrayData != nil {
            let card = arrayData![indexPath.row]
            cell!.displayCard(card)
            cell!.addRank(indexPath.row+1);
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let view = CardDetailsViewController()
        let card = arrayData![indexPath.row]
        
        view.card = card
        self.navigationController?.pushViewController(view, animated:false)
    }
    
    // UIScrollViewDelegate
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.isKindOfClass(UITableView.classForCoder()) {
            if arrayData!.count >= 100 {
                return
            }
            
            if (navigationItem.title == "Top Rated") {
                Database.sharedInstance().fetchTopRated(10, skip: Int32(arrayData!.count))
            } else if (navigationItem.title == "Top Viewed") {
                Database.sharedInstance().fetchTopViewed(10, skip: Int32(arrayData!.count))
            }        }
    }
    
    func updateData(sender: AnyObject) {
        let notif = sender as NSNotification
        let dict = notif.userInfo as [String: [Card]]
        var paths = [NSIndexPath]()

        for card in dict["data"]! {
            arrayData!.append(card)
            paths.append(NSIndexPath(forRow: arrayData!.count-1, inSection: 0))
            FileManager.sharedInstance().downloadCropImage(card, immediately:false)
            FileManager.sharedInstance().downloadCardImage(card, immediately:false)
        }

        if (self.isViewLoaded()) {
            tblList!.beginUpdates()
            tblList!.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimation.None)
            tblList!.endUpdates()
        }
    }
}
