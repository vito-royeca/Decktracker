
//
//  FeaturedViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/11/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class FeaturedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, HorizontalScrollTableViewCellDelegate, InAppPurchaseViewControllerDelegate, InAppPurchaseDelegate {
    
    let kHorizontalCellIdentifier   = "kHorizontalCellIdentifier"
    let kBannerCellIdentifier       = "kBannerCellIdentifier"
    let kDefaultCellIdentifier      = "kDefaultCellIdentifier"
    
    var btnWishList:UIBarButtonItem?
    var tblFeatured:UITableView?
    var colBanner:UICollectionView?
    var arrayData:[[String: [AnyObject]]]?
    var bannerCell:BannerScrollTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        
//        btnWishList = UIBarButtonItem(image:UIImage(named: "wishlist.png"), style:UIBarButtonItemStyle.Plain, target:self, action:"btnWishListTapped:")
//        self.navigationItem.rightBarButtonItem = btnWishList
        
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
        
//        bannerCell = tableView(tblFeatured!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? BannerScrollTableViewCell
//        bannerCell!.startSlideShow()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"topRatedDone:",  name:kFetchTopRatedDone, object:nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"topViewedDone:",  name:kFetchTopViewedDone, object:nil)
        
        Database.sharedInstance().fetchTopRated(10, skip: 0)
        Database.sharedInstance().fetchTopViewed(10, skip: 0)
        
        arrayData!.removeAtIndex(4)
        arrayData!.insert(["Highest Priced": Database.sharedInstance().fetchHighestPriced(10) as [DTCard]], atIndex: 4)
        tblFeatured?.reloadData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        bannerCell!.stopSlideShow()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
    }
    
    func loadData() {
        arrayData = [[String: [AnyObject]]]()
        
        arrayData!.append(["Random": Database.sharedInstance().fetchRandomCards(6) as [DTCard]])
        arrayData!.append(["Top Rated": [DTCard]()])
        arrayData!.append(["Top Viewed": [DTCard]()])
        arrayData!.append(["Sets": Database.sharedInstance().fetchSets(10) as [DTSet]])
        arrayData!.append(["Highest Priced": [DTCard]()])
        arrayData!.append(["In-App Purchase": ["Purchase Collections", "Restore Purchases"]])
        
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
        tblFeatured?.reloadData()
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
        tblFeatured?.reloadData()
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 132
        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
            return 170
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 6 {
            if !InAppPurchase.isProductPurchased(COLLECTIONS_IAP_PRODUCT_ID) {
                let view = InAppPurchaseViewController()
                
                view.productID = COLLECTIONS_IAP_PRODUCT_ID
                view.productDetails = ["name" : "Collections",
                                      "description": "Lets you manage your card collections."]
                view.delegate = self;
                self.navigationController?.pushViewController(view, animated:true)
            }
            
        } else if indexPath.row == 7 {
            let iap = InAppPurchase()
            
            iap.delegate = self
            iap.restorePurchases()
        }
    }
    
    // UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8 // arrayData.count + arrayData[5].count
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
            cell2!.selectionStyle = UITableViewCellSelectionStyle.None
            cell2!.setCollectionViewDataSourceDelegate(self, index: indexPath.row)
            cell = cell2
        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
            let row = arrayData![indexPath.row]
            let key = Array(row.keys)[0]
            
            var cell2 = tableView.dequeueReusableCellWithIdentifier(kHorizontalCellIdentifier) as HorizontalScrollTableViewCell?
            
            if cell2 == nil {
                cell2 = HorizontalScrollTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kHorizontalCellIdentifier)
            }
            cell2!.lblTitle?.text = key
            cell2!.selectionStyle = UITableViewCellSelectionStyle.None
            cell2!.setCollectionViewDataSourceDelegate(self, index: indexPath.row)
            cell = cell2
        } else {
            let row = arrayData![5]
            let key = Array(row.keys)[0]
            let dict = row[key] as [String]
            
            cell = tableView.dequeueReusableCellWithIdentifier(kDefaultCellIdentifier) as UITableViewCell?
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kDefaultCellIdentifier)
            }
            
            if indexPath.row == 5 {
                cell!.textLabel.text = key
                cell!.imageView.image = nil
                cell!.selectionStyle = UITableViewCellSelectionStyle.None
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
            else if indexPath.row == 6 {
                cell!.imageView.image = UIImage(named: "cards.png")
                cell!.textLabel.text = dict[0]
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else if indexPath.row == 7 {
                cell!.imageView.image = UIImage(named: "download.png")
                cell!.textLabel.text = dict[1]
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
        }

        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0  {
            let cell2 = cell as BannerScrollTableViewCell
            cell2.setCollectionViewDataSourceDelegate(self, index: indexPath.row)
        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
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
            
        } else if collectionView.tag == 1 || collectionView.tag == 2 || collectionView.tag == 4 {
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
        
        if collectionView.tag == 0 || collectionView.tag == 1 || collectionView.tag == 2 || collectionView.tag == 4 {
            let card = dict[indexPath.row] as DTCard
            let view2 = CardDetailsViewController()
            
            view2.addButtonVisible = true
            view2.card = card
            view = view2

        } else if collectionView.tag == 3 { // Sets
            let set = dict[indexPath.row] as DTSet
            let predicate = NSPredicate(format: "%K = %@", "set.name", set.name)
            var view2 = SetListViewController()
            
            view2.navigationItem.title = set.name
            view2.predicate = predicate
            view2.doSearch()
            view = view2
        }
        
        self.navigationController?.pushViewController(view!, animated:false)
    }
    
    // HorizontalScrollTableViewCellDelegate
    func seeAll(tag: NSInteger) {
        let row = arrayData![tag]
        let key = Array(row.keys)[0]
        var view:UIViewController?
        
        switch tag {
        case 1:
            var view2 = TopListViewController()
            view2.arrayData = row[key] as? [DTCard]
            Database.sharedInstance().fetchTopRated(20, skip: 10)
            view = view2;
        case 2:
            var view2 = TopListViewController()
            view2.arrayData = row[key] as? [DTCard]
            Database.sharedInstance().fetchTopViewed(20, skip: 10)
            view = view2;
        case 3:
            var view2 = SetListViewController()
            view2.arrayData = DTSet.MR_findAllSortedBy("releaseDate", ascending: false)
            view = view2;
        case 4:
            var view2 = TopListViewController()
            view2.arrayData = Database.sharedInstance().fetchHighestPriced(100) as [DTCard]?
            view = view2;
        default:
            println("tag = \(tag)")
        }
        
        view!.navigationItem.title = key
        navigationController?.pushViewController(view!, animated:true)
    }
    
    func btnWishListTapped(sender: AnyObject) {
        println("How I wish!")
//        Database.sharedInstance().uploadAllSetsToParse()
        let path = NSIndexPath(forRow: 0, inSection: 0)
        let path2 = NSIndexPath(forRow: 3, inSection: 0)
        
        let cell = tableView(tblFeatured!, cellForRowAtIndexPath: path) as? BannerScrollTableViewCell
        cell!.collectionView.setContentOffset(CGPoint(x:320*3, y:0), animated: true)
        cell!.collectionView.scrollToItemAtIndexPath(path2, atScrollPosition:UICollectionViewScrollPosition.Left, animated:false)
        
    }
    
    // InAppPurchaseViewControllerDelegate
    func productPurchaseSucceeded(productID: String)
    {
        if productID == COLLECTIONS_IAP_PRODUCT_ID {
            let view = self.tabBarController as MainViewController
            view.addCollectionsProduct()
        }
    }
    
    // InAppPurchaseDelegate
    func productPurchaseFailed(inAppPurchase: InAppPurchase, withMessage message: String) {
        let alert = UIAlertView(title: "Message",
            message:message,
            delegate:nil,
            cancelButtonTitle: "Ok")
        alert.show()
    }
    
    func purchaseRestoreSucceeded(inAppPurchase: InAppPurchase, withMessage message: String) {
        // Collections
        let view = self.tabBarController as MainViewController
        view.addCollectionsProduct()
    
        let alert = UIAlertView(title: "Message",
            message:message,
            delegate:nil,
            cancelButtonTitle: "Ok")
        alert.show()
    
#if !DEBUG
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("Settings",
            action:"Restore Purchases",
            label:"Succeeded",
            value:nil).build())
#endif
    }
    
    func purchaseRestoreFailed(inAppPurchase: InAppPurchase, withMessage message: String) {
        let alert = UIAlertView(title: "Message",
            message:message,
            delegate:nil,
            cancelButtonTitle: "Ok")
        alert.show()
    }
}
