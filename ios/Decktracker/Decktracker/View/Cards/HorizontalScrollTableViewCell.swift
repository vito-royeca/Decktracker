//
//  HorizontalScrollTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/13/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

protocol HorizontalScrollTableViewCellDelegate {
    func seeAll(tag: NSInteger)
}

class HorizontalScrollTableViewCell: UITableViewCell {

    let kThumbCellIdentifier  = "kThumbCellIdentifier"
    let kSetCellIdentifier    = "kSetCellIdentifier"
    let kHorizontalCellHeight = 170
    let kHorizontalItemCellWidth   = 95
    let kHorizontalItemCellHeight  = 132
    
    var lblTitle: UILabel?
    var btnSeeAll: UIButton?
    var collectionView: UICollectionView?
    var delegate:HorizontalScrollTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        var dX = CGFloat(10)
        var dY = CGFloat(0)
        var dWidth = (self.contentView.frame.size.width*3/4)-10
        var dHeight = CGFloat(38)
        
        lblTitle = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        contentView.addSubview(lblTitle!)
        
        dX = lblTitle!.frame.origin.x+lblTitle!.frame.size.width
        dWidth = self.contentView.frame.size.width-lblTitle!.frame.size.width-10
        btnSeeAll = UIButton(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        btnSeeAll!.setTitle("See All >", forState: UIControlState.Normal)
        btnSeeAll!.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        btnSeeAll!.titleLabel!.font = UIFont.systemFontOfSize(12)
        btnSeeAll!.addTarget(self, action: "seeAllTapped:", forControlEvents: .TouchUpInside)
        contentView.addSubview(btnSeeAll!)
        
        dWidth = CGFloat(kHorizontalItemCellWidth)
        dHeight = CGFloat(kHorizontalItemCellHeight)
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: dWidth, height: dHeight)
        flowLayout.headerReferenceSize = CGSize(width: CGFloat(0), height: CGFloat(0))
        flowLayout.footerReferenceSize = CGSize(width: CGFloat(0), height: CGFloat(0))
        flowLayout.minimumInteritemSpacing = CGFloat(0)
        flowLayout.minimumLineSpacing = CGFloat(0)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: CGFloat(5), bottom: 0, right: CGFloat(5))
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        dX = CGFloat(0)
        dY = CGFloat(btnSeeAll!.frame.origin.y+btnSeeAll!.frame.size.height)
        dWidth = self.contentView.frame.size.width
        collectionView = UICollectionView(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight), collectionViewLayout: flowLayout)
        collectionView!.registerClass(ThumbCollectionViewCell.self, forCellWithReuseIdentifier: kThumbCellIdentifier)
        collectionView!.registerClass(SetCollectionViewCell.self, forCellWithReuseIdentifier: kSetCellIdentifier)
        collectionView!.allowsSelection = true
        collectionView!.contentMode = UIViewContentMode.ScaleToFill
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.pagingEnabled = true
        self.contentView.addSubview(collectionView!)
        
        contentView.backgroundColor = UIColor.whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    
    func seeAllTapped(sender: UIButton) {
        delegate?.seeAll(collectionView!.tag)
    }
}
