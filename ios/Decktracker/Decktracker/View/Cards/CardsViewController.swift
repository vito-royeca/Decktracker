
//
//  CardsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/11/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, HorizontalScrollTableViewCellDelegate, InAppPurchaseViewControllerDelegate, MBProgressHUDDelegate {
    
    let kHorizontalCellIdentifier   = "kHorizontalCellIdentifier"
    let kBannerCellIdentifier       = "kBannerCellIdentifier"
    let kDefaultCellIdentifier      = "kDefaultCellIdentifier"

    var searchBar:UISearchBar?
    var tblFeatured:UITableView?
    var colBanner:UICollectionView?
    var arrayData:[[String: [String]]]?
    var searchSections:Array<[String: [String]]>?
    var searchSectionIndexTitles:[String]?
    var searchTimer:NSTimer?
    var bannerCell:BannerScrollTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)

        var btnSearchFilter = UIBarButtonItem(image: UIImage(named: "filter.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "btnSearchFilterTapped:")
        
        searchBar = UISearchBar()
        searchBar!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        searchBar!.placeholder = "Search Terms"
        searchBar!.delegate = self
        // Add a Done button in the keyboard
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: searchBar, action: "resignFirstResponder")
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        toolbar.items = [barButton]
        searchBar!.inputAccessoryView = toolbar
        
        tblFeatured = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblFeatured!.delegate = self
        tblFeatured!.dataSource = self
        tblFeatured!.registerNib(UINib(nibName: "BannerScrollTableViewCell", bundle: nil), forCellReuseIdentifier: kBannerCellIdentifier)
        tblFeatured!.registerNib(UINib(nibName: "HorizontalScrollTableViewCell", bundle: nil), forCellReuseIdentifier: kHorizontalCellIdentifier)

        self.navigationItem.titleView = self.searchBar
        self.navigationItem.rightBarButtonItem = btnSearchFilter
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
    
    func btnSearchFilterTapped(sender: AnyObject) {
        let view = SearchFilterViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(view, animated:true)
    }
    
    func loadData() {
        searchSections = nil
        searchSectionIndexTitles = nil
        
        if arrayData == nil {
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
                    if key == "Sets" {
                        continue
                    }
                    for x in value {
                        FileManager.sharedInstance().downloadCardImage(x, immediately:false)
                    }
                }
            }
        }
        
        tblFeatured!.reloadData()
    }

    func doSearch() {
        searchSections = Array<[String: [String]]>()
        searchSectionIndexTitles = [String]()
        var unsortedSections = [String: [String]]()
        
        var sorter = RLMSortDescriptor(property: "name", ascending: true)
//        var query = Dictionary<String, String>()
//        if NSUserDefaults.standardUserDefaults().objectForKey(SearchFilterViewController.Tags.SearchInName.rawValue) != nil {
//            query.updateValue(["Or": searchBar!.text], forKey: "Name")
//        }
//        if NSUserDefaults.standardUserDefaults().objectForKey(SearchFilterViewController.Tags.SearchInText.rawValue) != nil {
//            query.updateValue(["Or": searchBar!.text], forKey: "Text")
//        }
//        if NSUserDefaults.standardUserDefaults().objectForKey(SearchFilterViewController.Tags.SearchInFlavor.rawValue) != nil {
//            query.updateValue(["Or": searchBar!.text], forKey: "Flavor Text")
//        }
//        let cards = Database.sharedInstance().advanceFindCards(nil, withSorters: [sorter])
        
        let cards = Database.sharedInstance().findCards(searchBar!.text,  withSortDescriptors:[sorter], withSectionName:nil)
        
        for x in cards {
            let card = x as! DTCard
            let name = card.sectionNameInitial
            let predicate = NSPredicate(format: "sectionNameInitial = %@", name)
            
            var cardIds = Array<String>()
            
            for y in cards.objectsWithPredicate(predicate) {
                let z = y as! DTCard
                cardIds.append(z.cardId)
            }
            
            let index = advance(name!.startIndex, 1)
            var indexTitle = name!.substringToIndex(index)
            
            if name == "Blue" {
                indexTitle = "U"
            }
            
            unsortedSections.updateValue(cardIds, forKey: name!)
            if !contains(searchSectionIndexTitles!, indexTitle) {
                searchSectionIndexTitles!.append(indexTitle)
            }
        }
        
        for k in unsortedSections.keys.array.sorted(<) {
            let dict = [k: unsortedSections[k]!]
            searchSections!.append(dict)
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
            FileManager.sharedInstance().downloadCardImage(x, immediately:false)
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
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchTimer != nil && searchTimer!.valid {
            searchTimer!.invalidate()
        }
        searchTimer = NSTimer(timeInterval: 1.0, target: self, selector: "handleSearchBarEndTyping", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(searchTimer!, forMode: NSDefaultRunLoopMode)
    }
    
    func handleSearchBarEndTyping() {
        let hud = MBProgressHUD(view: view)
        view!.addSubview(hud)
        hud.delegate = self;
        
        if searchBar!.text.isEmpty {
            hud.showWhileExecuting("loadData", onTarget: self, withObject: nil, animated: true)
            if bannerCell != nil {
                bannerCell!.startSlideShow()
            }
            
        } else {
            if bannerCell != nil {
                bannerCell!.stopSlideShow()
            }
            hud.showWhileExecuting("doSearch", onTarget: self, withObject: nil, animated: true)
        }
    }
    
//    MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if searchSections != nil {
            return CGFloat(CARD_SUMMARY_VIEW_CELL_HEIGHT)
            
        } else {
            if indexPath.row == 0 {
                return 132
                
            } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
                return 170
                
            } else {
                return UITableViewAutomaticDimension
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchSections != nil {
            let dict = searchSections![indexPath.section]
            var key = dict.keys.array[0]
            var cardIds = dict[key]
            var cardId = cardIds![indexPath.row]
            let card = DTCard(forPrimaryKey: cardId)
            
            let iaps = Database.sharedInstance().inAppSettingsForSet(card!.set.setId)
            if iaps != nil {
                return
            }
            
            cardIds = Array()
            for d in searchSections! {
                key = d.keys.array[0]
                for cardId in d[key]! {
                    cardIds!.append(cardId)
                }
            }
            
            let view = CardDetailsViewController()
            view.addButtonVisible = true
            view.cardIds = cardIds
            view.cardId = cardId
            
            self.navigationController?.pushViewController(view, animated:true)
        }
    }

//    MARK: UITableViewDataSource
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        if searchSections != nil {
            return searchSectionIndexTitles
        
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchSections != nil {
            let dict = searchSections![section]
            let key = dict.keys.array[0]
            let cardIds = dict[key]
            let cardsString = cardIds!.count > 1 ? "cards" : "card"
            return "\(key) (\(cardIds!.count) \(cardsString))"
        
        } else {
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchSections != nil {
            return searchSections!.count
        
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchSections != nil {
            let dict = searchSections![section]
            let key = dict.keys.array[0]
            return dict[key]!.count
        
        } else {
            return arrayData!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchSections != nil {
            var cell:UITableViewCell?
            
            let dict = searchSections![indexPath.section]
            let key = dict.keys.array[0]
            let cardIds = dict[key]
            let cardId = cardIds![indexPath.row]
            var cardSummaryView:CardSummaryView?
            
            if let x = tableView.dequeueReusableCellWithIdentifier(kCardInfoViewIdentifier) as? UITableViewCell {
                cell = x
                for subView in cell!.contentView.subviews {
                    if subView is CardSummaryView {
                        cardSummaryView = subView as? CardSummaryView
                        break
                    }
                }
                
            } else {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kCardInfoViewIdentifier)
                cardSummaryView = NSBundle.mainBundle().loadNibNamed("CardSummaryView", owner: self, options: nil).first as? CardSummaryView
                cardSummaryView!.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: CGFloat(CARD_SUMMARY_VIEW_CELL_HEIGHT))
                cell!.contentView.addSubview(cardSummaryView!)
            }
            
            cell!.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            cardSummaryView!.displayCard(cardId)
            return cell!
        
        } else {
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
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if searchSections != nil {
            
        } else {
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
    }
    
//    MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchSections != nil {
            return 0
        
        } else {
            let row = arrayData![collectionView.tag]
            let key = Array(row.keys)[0]
            let dict = row[key]!
            return dict.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if searchSections != nil {
            return UICollectionViewCell()
            
        } else {
            var cell:UICollectionViewCell?
            
            let row = arrayData![collectionView.tag]
            let key = Array(row.keys)[0]
            let dict = row[key]!
            
            if collectionView.tag == 0 {
                let cardId = dict[indexPath.row]
                var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("kBannerCellIdentifier", forIndexPath:indexPath) as! CardImageCollectionViewCell
                cell2.displayCard(cardId, cropped: true, showName: true, showSetIcon: true)
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
    }
    
//    MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if searchSections != nil {
            
        } else {
            let row = arrayData![collectionView.tag]
            let key = Array(row.keys)[0]
            let dict = row[key]!
            var view:UIViewController?
            
            if collectionView.tag == 0 || collectionView.tag == 1 || collectionView.tag == 2 {
                let cardId = dict[indexPath.row]
                let card = DTCard(forPrimaryKey: cardId)
                let dict = Database.sharedInstance().inAppSettingsForSet(card!.set.setId)
                
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
                    view2.cardId = card!.cardId
                    view = view2
                }
                
            } else if collectionView.tag == 3 { // Sets
                let setId = dict[indexPath.row]
                let set = DTSet(forPrimaryKey: setId)
                let dict = Database.sharedInstance().inAppSettingsForSet(set!.setId)
                
                if dict != nil {
                    let view2 = InAppPurchaseViewController()
                    
                    view2.productID = dict["In-App Product ID"] as! String
                    view2.delegate = self
                    view2.productDetails = ["name" : dict["In-App Display Name"] as! String,
                        "description": dict["In-App Description"] as! String]
                    view = view2
                    
                } else {
                    let predicate = NSPredicate(format: "%K = %@", "set.name", set!.name)
                    let view2 = CardListViewController()
                    
                    view2.navigationItem.title = set!.name
                    view2.predicate = predicate
                    view = view2
                }
            }
            
            if view != nil {
                self.navigationController?.pushViewController(view!, animated:false)
            }
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
        navigationController?.pushViewController(view!, animated:false)
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
        if arrayData != nil {
            if scrollView.tag == 0 {
                let row = arrayData![scrollView.tag]
                let key = Array(row.keys)[0]
                let dict = row[key]!
                bannerCell?.continueScrolling(dict)
                
            }
        }
    }
    
//    MARK: MBProgressHUDDelegate methods
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
}
