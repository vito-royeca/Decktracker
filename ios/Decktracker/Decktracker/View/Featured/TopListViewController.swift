//
//  TopListViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class TopListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, InAppPurchaseViewControllerDelegate {

    let kSearchResultsIdentifier = "kSearchResultsIdentifier"
    
    var viewButton:UIBarButtonItem?
    var tblList:UITableView?
    var colList:UICollectionView?
    var arrayData:[DTCard]?
    var viewMode:CardViewMode?
    var viewLoadedOnce = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewButton = UIBarButtonItem(image: UIImage(named: "insert_table.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "viewButtonTapped")
        
        navigationItem.rightBarButtonItem = viewButton
        
        
        if let value = NSUserDefaults.standardUserDefaults().stringForKey(kCardViewMode) {
            if value == CardViewMode.ByList.description {
                self.viewMode = CardViewMode.ByList
                self.showTableView()
            
            } else if value == CardViewMode.ByGrid2x2.description {
                self.viewMode = CardViewMode.ByGrid2x2
                self.showGridView()
            
            } else if value == CardViewMode.ByGrid3x3.description {
                self.viewMode = CardViewMode.ByGrid3x3
                self.showGridView()
            
            } else {
                self.viewMode = CardViewMode.ByList
                self.showTableView()
            }
            
        } else {
            self.viewMode = CardViewMode.ByList
            self.showTableView()
        }
        
        self.loadData()
        self.viewLoadedOnce = false
        
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
    
    func hidesBottomBarWhenPushed() -> Bool {
        return true
    }
    
    func viewButtonTapped() {
        let viewOptions = [CardViewMode.ByList.description,
            CardViewMode.ByGrid2x2.description,
            CardViewMode.ByGrid3x3.description]
        var initialSelection = 0
        
        switch self.viewMode! {
        case .ByList:
            initialSelection = 0
        case .ByGrid2x2:
            initialSelection = 1
        case .ByGrid3x3:
            initialSelection = 2
        default:
            break
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            
            switch selectedIndex {
            case 0:
                self.viewMode = .ByList
                self.showTableView()
            case 1:
                self.viewMode = .ByGrid2x2
                self.showGridView()
            case 2:
                self.viewMode = .ByGrid3x3
                self.showGridView()
            default:
                break
            }
            
            NSUserDefaults.standardUserDefaults().setObject(self.viewMode!.description, forKey: kCardViewMode)
            NSUserDefaults.standardUserDefaults().synchronize()
            self.loadData()
        }
        
        ActionSheetStringPicker.showPickerWithTitle("View As",
            rows: viewOptions,
            initialSelection: initialSelection,
            doneBlock: doneBlock,
            cancelBlock: nil,
            origin: view)
    }
    
    func loadData() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopRatedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"updateData:",  name:kFetchTopRatedDone, object:nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFetchTopViewedDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"updateData:",  name:kFetchTopViewedDone, object:nil)
    }
    
    func showTableView() {
        let y = viewLoadedOnce ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height
        let height = view.frame.size.height - y
        var frame = CGRect(x:0, y:y, width:view.frame.width, height:height)
        
        tblList = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblList!.delegate = self
        tblList!.dataSource = self
        tblList!.registerNib(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: kSearchResultsIdentifier)
        
        if colList != nil {
            colList!.removeFromSuperview()
        }
        view.addSubview(tblList!)
    }
    
    func showGridView() {
        let y = viewLoadedOnce ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height
        let height = view.frame.size.height - y
        let divisor:CGFloat = viewMode == CardViewMode.ByGrid2x2 ? 2 : 3
        var frame = CGRect(x:0, y:y, width:view.frame.width, height:height)
        
        
        let layout = CSStickyHeaderFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width:view.frame.width, height: 22)
        layout.itemSize = CGSize(width: frame.width/divisor, height: frame.height/divisor)
        
        colList = UICollectionView(frame: frame, collectionViewLayout: layout)
        colList!.dataSource = self
        colList!.delegate = self
        colList!.registerClass(CardListCollectionViewCell.self, forCellWithReuseIdentifier: "Card")
        colList!.backgroundColor = UIColor.lightGrayColor()
        
        if tblList != nil {
            tblList!.removeFromSuperview()
        }
        view.addSubview(colList!)
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
    
    // UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayData!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let card = arrayData![indexPath.row] as DTCard
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Card", forIndexPath: indexPath) as CardListCollectionViewCell
        
        cell.displayCard(card)
        cell.addRank(indexPath.row+1)
        return cell
    }
    
    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
        
        if scrollView.isKindOfClass(UITableView.classForCoder()) ||
           scrollView.isKindOfClass(UICollectionView.classForCoder()) {
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
                FileManager.sharedInstance().downloadCardImage(card, immediately:false)
            }
        }

        if paths.count > 0 && tblList != nil {
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
