
//
//  FeaturedViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/11/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class FeaturedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let kFeaturedCellIdentifier   = "kFeaturedCellIdentifier"
    
    var tblFeatured:UITableView?
    var arrayData:[[String: [AnyObject]]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        
        tblFeatured = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblFeatured!.delegate = self
        tblFeatured!.dataSource = self
        tblFeatured!.registerClass(FeaturedTableViewCell.self, forCellReuseIdentifier: kFeaturedCellIdentifier)
        view.addSubview(tblFeatured!)
        
        self.navigationItem.title = "Featured"
        
        self.loadData()
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
        arrayData = [[String: [AnyObject]]]()
        
        arrayData!.append(["Random": Database.sharedInstance().getRandomCards(6) as [Card]])
        arrayData!.append(["Top Rated": Database.sharedInstance().getRandomCards(10) as [Card]])
        arrayData!.append(["Top Viewed": Database.sharedInstance().getRandomCards(10) as [Card]])
        arrayData!.append(["Sets and Expansions": Database.sharedInstance().getSets(10) as [Set]])
        arrayData!.append(["In-App Purchase": ["Purchase Collections", "Restore Purchases"]])
        
        for dict in arrayData! {
            for (key,value) in dict {
                for x in value {
                    if x.isKindOfClass(Card.classForCoder()) {
                        FileManager.sharedInstance().downloadCropImage(x as Card, immediately:false)
                        FileManager.sharedInstance().downloadCardImage(x as Card, immediately:false)
                    }
                }
            }
        }
        tblFeatured?.reloadData()
    }

    // UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 {
            return 132
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 || section == 2 || section == 3 || section == 4 {
            let row = arrayData![section]
            return Array(row.keys)[0]
        }
        
        return nil
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 1 || section == 2 || section == 3 {
//            return 30
//        } else {
//            return 0
//        }
//    }
//    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        if section == 1 || section == 2 || section == 3 {
//            let view = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
//            let label = UILabel(frame: CGRectMake(10, 0, tableView.bounds.size.width-70, 30))
//            let button = UIButton(frame: CGRectMake(label.frame.origin.x+label.frame.size.width, 0, tableView.bounds.size.width-label.frame.size.width, 30))
//            
//            let row = arrayData![section]
//            label.text = Array(row.keys)[0]
//            button.titleLabel?.text = "See All>"
//            
//            view.backgroundColor = UIColor.whiteColor()
//            view.addSubview(label)
//            view.addSubview(button)
//            
//            return view
//        }
//        
//        return nil
//    }
    
    // UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return arrayData!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            let row = arrayData![section]
            let key = Array(row.keys)[0]
            let dict = row[key]!
            return dict.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 {
            var cell2 = tableView.dequeueReusableCellWithIdentifier(kFeaturedCellIdentifier) as FeaturedTableViewCell?
            if cell2 == nil {
                cell2 = FeaturedTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kFeaturedCellIdentifier)
                cell2!.setCollectionViewDataSourceDelegate(self, index: indexPath.row)
            }
            cell = cell2
        } else if indexPath.section == 4 {
            cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell") as UITableViewCell?
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "DefaultCell")
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            
            if indexPath.row == 0 {
                cell!.imageView.image = UIImage(named: "cards.png")
                cell?.textLabel.text = "Purchase Collections"
            } else if indexPath.row == 1 {
                cell!.imageView.image = UIImage(named: "download.png")
                cell?.textLabel.text = "Restore Purchases"
            }
        } else {
            cell = UITableViewCell()
        }
        

        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: FeaturedTableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 {
            cell.setCollectionViewDataSourceDelegate(self, index: indexPath.section)
        }
    }
    
    // UICollectionViewDataSource
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
            let card = dict[indexPath.row] as Card
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("kBannerCellIdentifier", forIndexPath:indexPath) as BannerCollectionViewCell
            cell2.displayCard(card)
            cell = cell2
            
        } else if collectionView.tag == 1 || collectionView.tag == 2 {
            let card = dict[indexPath.row] as Card
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("kThumbCellIdentifier", forIndexPath:indexPath) as ThumbCollectionViewCell
            cell2.displayCard(card)
            cell = cell2
        }  else if collectionView.tag == 3 {
            let set = dict[indexPath.row] as Set
            var cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("kSetCellIdentifier", forIndexPath:indexPath) as SetCollectionViewCell
            cell2.displaySet(set)
            cell = cell2
        }
        
        return cell!
    }
    
    // UICollectionViewDelegate
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let collectionViewHeight = CGRectGetHeight(collectionView.frame)
////        collectionView.setContentInset(UIEdgeInsetsMake(collectionViewHeight / 2, 0, collectionViewHeight / 2, 0))
//        
//        let cell = collectionView.cellForItemAtIndexPath(indexPath)
//        let offset = CGPointMake(0,  cell!.center.y - collectionViewHeight / 2)
//        collectionView.setContentOffset(offset, animated:true)
//    }
    
    // UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if !scrollView.isKindOfClass(UICollectionView.classForCoder()) {
            return
        }
        
        let collectionView = scrollView as UICollectionView
        var index  = 0
        
        for cell in collectionView.visibleCells() {
            if ((cell.center.x>0) && (cell.center.x<UIScreen.mainScreen().bounds.size.width)) {
                let path = NSIndexPath(forRow: index, inSection:0)
                
                collectionView.scrollToItemAtIndexPath(path, atScrollPosition:UICollectionViewScrollPosition.CenteredHorizontally, animated:true)
                break;
            }
            index++
        }
    }
}
