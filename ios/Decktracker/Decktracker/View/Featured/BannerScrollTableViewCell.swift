//
//  BannerScrollTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/14/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class BannerScrollTableViewCell: UITableViewCell {

    let kBannerCellIdentifier  = "kBannerCellIdentifier"
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arrayData:[AnyObject]?
    var slideshowTimer:NSTimer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.registerNib(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kBannerCellIdentifier)
        collectionView.allowsSelection = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: protocol<UICollectionViewDataSource, UICollectionViewDelegate>, index: NSInteger) {
        
        collectionView.dataSource = dataSourceDelegate
        collectionView.delegate = dataSourceDelegate
        collectionView.tag = index
        collectionView.reloadData()
    }

    func showSlide() {
        if (collectionView.indexPathsForVisibleItems().count > 0)
        {
            let indexPath = collectionView.indexPathsForVisibleItems()[0] as! NSIndexPath
            let rows = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0)
            var row = indexPath.row
            var newIndexPath:NSIndexPath?
            var bWillSlide = true
            
            if row == rows!-2 {
                row = 1
                bWillSlide = false
                
            } else {
                row++
            }
            
            newIndexPath = NSIndexPath(forRow: row, inSection: 0)
#if DEBUG
            println("Scrolling to... \(newIndexPath!)")
#endif
            collectionView.scrollToItemAtIndexPath(newIndexPath!, atScrollPosition: UICollectionViewScrollPosition.Left, animated: bWillSlide)
        }
    }
    
    func startSlideShow() {
        slideshowTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: "showSlide", userInfo: nil, repeats: true)
    }
    
    func stopSlideShow() {
        slideshowTimer!.invalidate()
        slideshowTimer = nil
    }
    
    func continueScrolling(data: Array<DTCard>) {
        // Calculate where the collection view should be at the right-hand end item
        let offset = collectionView.frame.size.width * CGFloat(data.count-1)
        var newIndexPath:NSIndexPath?
        
        if (collectionView.contentOffset.x == offset) {
            newIndexPath = NSIndexPath(forItem: 1, inSection: 0)
            
        } else if (collectionView.contentOffset.x == 0)  {
            // user is scrolling to the left from the first item to the fake 'item N'.
            // reposition offset to show the 'real' item N at the right end end of the collection view
            newIndexPath = NSIndexPath(forItem: data.count-2, inSection: 0)
        }
        
        if newIndexPath != nil {
            collectionView.scrollToItemAtIndexPath(newIndexPath!, atScrollPosition:UICollectionViewScrollPosition.Left, animated:false)
        }
    }
}
