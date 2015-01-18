
//
//  FeaturedViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/11/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class FeaturedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, HorizontalScrollTableViewCellDelegate, InAppPurchaseViewControllerDelegate {
    
    let kHorizontalCellIdentifier   = "kHorizontalCellIdentifier"
    let kBannerCellIdentifier       = "kBannerCellIdentifier"
    let kDefaultCellIdentifier      = "kDefaultCellIdentifier"
    
    var tblFeatured:UITableView?
    var colBanner:UICollectionView?
    var arrayData:[[String: [AnyObject]]]?
    var bannerCell:BannerScrollTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        
        tblFeatured = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblFeatured!.delegate = self
        tblFeatured!.dataSource = self
        tblFeatured!.registerNib(UINib(nibName: "BannerScrollTableViewCell", bundle: nil), forCellReuseIdentifier: kBannerCellIdentifier)
        tblFeatured!.registerNib(UINib(nibName: "HorizontalScrollTableViewCell", bundle: nil), forCellReuseIdentifier: kHorizontalCellIdentifier)
        
        view.addSubview(tblFeatured!)
        
        self.navigationItem.title = "Featured"
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"topRatedDone:",  name:kFetchTopRatedDone, object:nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"topViewedDone:",  name:kFetchTopViewedDone, object:nil)
        
        Database.sharedInstance().fetchTopRated(10, skip: 0)
        Database.sharedInstance().fetchTopViewed(10, skip: 0)
        
        tblFeatured!.reloadData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if bannerCell != nil {
            bannerCell!.stopSlideShow()
            bannerCell = nil
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
    }
    
    /*func specialButtonTapped() {
        let view = SpecialListsViewController()
        
        self.navigationController?.pushViewController(view, animated:false)
    }*/
    
    func loadData() {
        arrayData = [[String: [AnyObject]]]()
        
        arrayData!.append(["Random": Database.sharedInstance().fetchRandomCards(6) as [DTCard]])
        arrayData!.append(["Top Rated": [DTCard]()])
        arrayData!.append(["Top Viewed": [DTCard]()])
        arrayData!.append(["Sets": Database.sharedInstance().fetchSets(10) as [DTSet]])
        
        for dict in arrayData! {
            for (key,value) in dict {
                for x in value {
                    if x.isKindOfClass(DTCard.classForCoder()) {
                        FileManager.sharedInstance().downloadCropImage(x as DTCard, immediately:false)
                        FileManager.sharedInstance().downloadCardImage(x as DTCard, immediately:false)
                    }
                }
            }
        }
        tblFeatured!.reloadData()
    }

    func topRatedDone(sender: AnyObject) {
        reloadTable(sender, key: "Top Rated")
    }
    
    func topViewedDone(sender: AnyObject) {
        reloadTable(sender, key: "Top Viewed")
    }
    
    func reloadTable(sender: AnyObject, key: String) {
        let notif = sender as NSNotification
        let dict = notif.userInfo as [String: [AnyObject]]
        let cards = dict["data"]! as [AnyObject]
        let newRow = [key: cards]
        
        for x in cards {
            FileManager.sharedInstance().downloadCropImage(x as? DTCard, immediately:false)
            FileManager.sharedInstance().downloadCardImage(x as? DTCard, immediately:false)
        }
        
        var i = 0
        for y in arrayData! {
            for (k, value) in y {
                if k == key {
                    arrayData!.removeAtIndex(i)
                    arrayData!.insert(newRow, atIndex: i)
                    break
                }
            }
            i++
        }
        tblFeatured!.reloadData()
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 132
            
        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            return 170
            
        } else {
            return UITableViewAutomaticDimension
        }
    }

    // UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if indexPath.row == 0 {
            let row = arrayData![indexPath.row]
            let key = Array(row.keys)[0]
            
            var cell2 = tableView.dequeueReusableCellWithIdentifier(kBannerCellIdentifier) as BannerScrollTableViewCell?
            
            if cell2 == nil {
                cell2 = BannerScrollTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kBannerCellIdentifier)
            }
            cell = cell2

        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            let row = arrayData![indexPath.row]
            let key = Array(row.keys)[0]
            
            var cell2 = tableView.dequeueReusableCellWithIdentifier(kHorizontalCellIdentifier) as HorizontalScrollTableViewCell?
            
            if cell2 == nil {
                cell2 = HorizontalScrollTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kHorizontalCellIdentifier)
            }
            cell2!.lblTitle?.text = key
            cell = cell2
        }

        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0  {
            let cell2 = cell as BannerScrollTableViewCell
            cell2.setCollectionViewDataSourceDelegate(self, index: indexPath.row)
            
            if bannerCell == nil {
                bannerCell = cell2
                bannerCell!.startSlideShow()
            }
            
        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            let cell2 = cell as HorizontalScrollTableViewCell
            cell2.setCollectionViewDataSourceDelegate(self, index: indexPath.row)
            cell2.delegate = self
        }
    }
    
    // UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let row = arrayData![collectionView.tag]
        let key = Array(row.keys)[0]
        let dict = row[key]!
        return dict.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let row = arrayData![collectionView.tag]
        let key = Array(row.keys)[0]
        let dict = row[key]!
        
        var cell:UICollectionViewCell?
        
        if collectionView.tag == 0 {
            let card = dict[indexPath.row] as DTCard
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier(kBannerCellIdentifier, forIndexPath:indexPath) as BannerCollectionViewCell
            cell2.displayCard(card)
            cell = cell2
            
        } else if collectionView.tag == 1 || collectionView.tag == 2 {
            let card = dict[indexPath.row] as DTCard
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("kThumbCellIdentifier", forIndexPath:indexPath) as ThumbCollectionViewCell
            cell2.displayCard(card)
            cell = cell2
            
        }  else if collectionView.tag == 3 {
            let set = dict[indexPath.row] as DTSet
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("kSetCellIdentifier", forIndexPath:indexPath) as SetCollectionViewCell
            cell2.displaySet(set)
            cell = cell2
        }
        
        return cell!
    }
    
    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let row = arrayData![collectionView.tag]
        let key = Array(row.keys)[0]
        let dict = row[key]!
        var view:UIViewController?
        
        if collectionView.tag == 0 || collectionView.tag == 1 || collectionView.tag == 2 {
            let card = dict[indexPath.row] as DTCard
            let view2 = CardDetailsViewController()
            
            view2.addButtonVisible = true
            view2.card = card
            view = view2

        } else if collectionView.tag == 3 { // Sets
            let set = dict[indexPath.row] as DTSet
            let dict = Database.sharedInstance().inAppSettingsForSet(set)
            
            if dict != nil {
                let view2 = InAppPurchaseViewController()
                
                view2.productID = dict["In-App Product ID"] as String
                view2.delegate = self
                view2.productDetails = ["name" : dict["In-App Display Name"] as String,
                                        "description": dict["In-App Description"] as String]
                view = view2
                
            } else {
                let predicate = NSPredicate(format: "%K = %@", "set.name", set.name)
                let view2 = CardListViewController()
                
                view2.navigationItem.title = set.name
                view2.predicate = predicate
                view = view2
            }
        }
        
        if view != nil {
            self.navigationController?.pushViewController(view!, animated:false)
        }
    }
    
    // HorizontalScrollTableViewCellDelegate
    func seeAll(tag: NSInteger) {
        let row = arrayData![tag]
        let key = Array(row.keys)[0]
        var view:UIViewController?
        
        switch tag {
        case 1:
            let view2 = TopListViewController()
            view2.arrayData = row[key] as? [DTCard]
            Database.sharedInstance().fetchTopRated(20, skip: 10)
            view = view2;
        case 2:
            let view2 = TopListViewController()
            view2.arrayData = row[key] as? [DTCard]
            Database.sharedInstance().fetchTopViewed(20, skip: 10)
            view = view2;
        case 3:
            let view2 = SetListViewController()
            view2.arrayData = DTSet.MR_findAllSortedBy("releaseDate", ascending: false)
            view = view2;
        default:
            println("tag = \(tag)")
        }
        
        view!.navigationItem.title = key
        navigationController?.pushViewController(view!, animated:true)
    }
    
    // InAppPurchaseViewControllerDelegate
    func productPurchaseSucceeded(productID: String)
    {
        Database.sharedInstance().loadInAppSets()
        arrayData!.removeLast()
        arrayData!.append(["Sets": Database.sharedInstance().fetchSets(10) as [DTSet]])
        tblFeatured!.reloadData()
    }
}
