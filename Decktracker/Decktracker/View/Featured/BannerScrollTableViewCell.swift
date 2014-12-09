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
    var slideshowTimer:NSTimer?
    var indexPath:NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView!.registerNib(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kBannerCellIdentifier)
        collectionView!.allowsSelection = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: protocol<UICollectionViewDataSource, UICollectionViewDelegate>, index: NSInteger) {
        
        collectionView!.dataSource = dataSourceDelegate
        collectionView!.delegate = dataSourceDelegate
        collectionView!.tag = index
        
        collectionView!.reloadData()
    }

    func showSlide() {
//        collectionView!.selectItemAtIndexPath(indexPath!, animated:true, scrollPosition:UICollectionViewScrollPosition.None)
        println("Scrolling to... \(indexPath!)")
        collectionView!.setContentOffset(CGPoint(x: 320*indexPath!.row, y: 0), animated: true)
        collectionView!.setNeedsDisplayInRect(CGRect(x: 320*indexPath!.row, y: 0, width: 320, height: 132))
        collectionView!.scrollToItemAtIndexPath(indexPath!, atScrollPosition:UICollectionViewScrollPosition.Left, animated:false)
        
        if indexPath?.row == 5 {
            indexPath = NSIndexPath(forRow: 0, inSection: 0)
        } else {
            indexPath = NSIndexPath(forRow: indexPath!.row+1, inSection: 0)
        }
    }
    
    func startSlideShow() {
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
        slideshowTimer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "showSlide", userInfo: nil, repeats: true)
    }
    
    func stopSlideShow() {
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }
}
