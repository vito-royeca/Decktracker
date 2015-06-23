
//
//  CardsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/11/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, HorizontalScrollTableViewCellDelegate, InAppPurchaseViewControllerDelegate {
    
    let kHorizontalCellIdentifier   = "kHorizontalCellIdentifier"
    let kBannerCellIdentifier       = "kBannerCellIdentifier"
    let kDefaultCellIdentifier      = "kDefaultCellIdentifier"
    
    var searchBar:UISearchBar?
    var tblFeatured:UITableView?
    var colBanner:UICollectionView?
    var arrayData:[[String: [String]]]?
    var bannerCell:BannerScrollTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)

        var btnAdvance = UIBarButtonItem(image: UIImage(named: "filter.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "btnAdvanceTapped")
        
        searchBar = UISearchBar()
        searchBar!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        searchBar!.placeholder = "Search"
        searchBar!.delegate = self
        
        tblFeatured = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblFeatured!.delegate = self
        tblFeatured!.dataSource = self
        tblFeatured!.registerNib(UINib(nibName: "BannerScrollTableViewCell", bundle: nil), forCellReuseIdentifier: kBannerCellIdentifier)
        tblFeatured!.registerNib(UINib(nibName: "HorizontalScrollTableViewCell", bundle: nil), forCellReuseIdentifier: kHorizontalCellIdentifier)

        self.navigationItem.leftBarButtonItem = btnAdvance;
        self.navigationItem.titleView = self.searchBar;
        view.addSubview(tblFeatured!)
        
        self.navigationItem.title = "Featured"
        self.loadData()
        
//        Database.sharedInstance().updateParseCards()
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
    
    func loadData() {
        arrayData = [[String: [String]]]()
        
        let arrRandom = Database.sharedInstance().fetchRandomCards(6, withPredicate: nil, includeInAppPurchase: false) as! [DTCard]
        var array:[String] = Array()
        array.append(arrRandom.last!.cardId)
        for card in arrRandom {
            array.append(card.cardId)
        }
        array.append(arrRandom.first!.cardId)
        arrayData!.append(["Random": array])
        arrayData!.append(["Top Rated": [String]()])
        arrayData!.append(["Top Viewed": [String]()])
        arrayData!.append(["Sets": Database.sharedInstance().fetchSets(10) as! [String]!])
        
        for dict in arrayData! {
            for (key,value) in dict {
                for x in value {
//                    if x.isKindOfClass(String.class()) {
                        FileManager.sharedInstance().downloadCardImage(x, immediately:false)
//                    }
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
        let notif = sender as! NSNotification
        let dict = notif.userInfo as! [String: [String]]
        let cardIds = dict["cardIds"]! as [String]
        let newRow = [key: cardIds]
        
        for x in cardIds {
//            if x.isKindOfClass(String.class()) {
                FileManager.sharedInstance().downloadCardImage(x, immediately:false)
//            }
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

//    MARK: UISearchBarDelegate
    
    
//    MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 132
            
        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            return 170
            
        } else {
            return UITableViewAutomaticDimension
        }
    }

//    MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if indexPath.row == 0 {
            var cell2:BannerScrollTableViewCell?
            
            if let x =  tableView.dequeueReusableCellWithIdentifier(kBannerCellIdentifier) as? BannerScrollTableViewCell {
                cell2 = x
            } else {
                cell2 = BannerScrollTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kBannerCellIdentifier)
            }
            cell = cell2

        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            let row = arrayData![indexPath.row]
            let key = Array(row.keys)[0]
            var cell2:HorizontalScrollTableViewCell?
            
            if let x = tableView.dequeueReusableCellWithIdentifier(kHorizontalCellIdentifier) as? HorizontalScrollTableViewCell {
                cell2 = x
            } else {
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
            let cell2 = cell as! BannerScrollTableViewCell
            cell2.setCollectionViewDataSourceDelegate(self, index: indexPath.row)
            
            if bannerCell == nil {
                bannerCell = cell2
                bannerCell!.startSlideShow()
            }
            
        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            let cell2 = cell as! HorizontalScrollTableViewCell
            cell2.setCollectionViewDataSourceDelegate(self, index: indexPath.row)
            cell2.delegate = self
        }
    }
    
//    MARK: UICollectionViewDataSource
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
            let cardId = dict[indexPath.row]
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier(kBannerCellIdentifier, forIndexPath:indexPath) as! BannerCollectionViewCell
            cell2.displayCard(cardId)
            cell = cell2
            
        } else if collectionView.tag == 1 || collectionView.tag == 2 {
            let cardId = dict[indexPath.row]
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("kThumbCellIdentifier", forIndexPath:indexPath) as! ThumbCollectionViewCell
            cell2.displayCard(cardId)
            cell = cell2
            
        }  else if collectionView.tag == 3 {
            let setId = dict[indexPath.row]
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("kSetCellIdentifier", forIndexPath:indexPath) as! SetCollectionViewCell
            cell2.displaySet(setId)
            cell = cell2
        }
        
        return cell!
    }
    
//    MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let row = arrayData![collectionView.tag]
        let key = Array(row.keys)[0]
        let dict = row[key]!
        var view:UIViewController?
        
        if collectionView.tag == 0 || collectionView.tag == 1 || collectionView.tag == 2 {
            let cardId = dict[indexPath.row]
            let card = DTCard(forPrimaryKey: cardId)
            let dict = Database.sharedInstance().inAppSettingsForSet(card.set)
            
            if dict != nil {
                let view2 = InAppPurchaseViewController()
                
                view2.productID = dict["In-App Product ID"] as! String
                view2.delegate = self
                view2.productDetails = ["name" : dict["In-App Display Name"] as! String,
                    "description": dict["In-App Description"] as! String]
                view = view2
                
            } else {
                let view2 = CardDetailsViewController()
            
                view2.addButtonVisible = true
                view2.cardId = card.cardId
                view = view2
            }

        } else if collectionView.tag == 3 { // Sets
            let setId = dict[indexPath.row]
            let set = DTSet(forPrimaryKey: setId)
            let dict = Database.sharedInstance().inAppSettingsForSet(set)
            
            if dict != nil {
                let view2 = InAppPurchaseViewController()
                
                view2.productID = dict["In-App Product ID"] as! String
                view2.delegate = self
                view2.productDetails = ["name" : dict["In-App Display Name"] as! String,
                                        "description": dict["In-App Description"] as! String]
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
    
//    MARK: HorizontalScrollTableViewCellDelegate
    func seeAll(tag: NSInteger) {
        let row = arrayData![tag]
        let key = Array(row.keys)[0]
        var view:UIViewController?
        
        switch tag {
        case 1:
            let view2 = TopListViewController()
            view2.cardIds = row[key]
            Database.sharedInstance().fetchTopRated(20, skip: 10)
            view = view2;
        case 2:
            let view2 = TopListViewController()
            view2.cardIds = row[key]
            Database.sharedInstance().fetchTopViewed(20, skip: 10)
            view = view2;
        case 3:
            let view2 = SetListViewController()
            let predicate = NSPredicate(format: "magicCardsInfoCode != %@", "")
            var arrayData = [AnyObject]()
            for set in DTSet.objectsWithPredicate(predicate).sortedResultsUsingProperty("releaseDate", ascending: false) {
                arrayData.append(set)
            }
            view2.arrayData = arrayData
            view = view2;
        default:
            println("tag = \(tag)")
        }
        
        view!.navigationItem.title = key
        navigationController?.pushViewController(view!, animated:true)
    }
    
//    MARK: InAppPurchaseViewControllerDelegate
    func productPurchaseCancelled() {
        // empty implementation
    }
    
    func productPurchaseSucceeded(productID: String)
    {
        Database.sharedInstance().loadInAppSets()
        arrayData!.removeLast()
        arrayData!.append(["Sets": Database.sharedInstance().fetchSets(10) as! [String]])
        tblFeatured!.reloadData()
    }
    
//    MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            let row = arrayData![scrollView.tag]
            let key = Array(row.keys)[0]
            let dict = row[key]!
            bannerCell?.continueScrolling(dict)
            
        }
    }
}
