//
//  FeaturedTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/11/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class FeaturedTableViewCell: UITableViewCell {

    let kBannerCellIdentifier = "kBannerCellIdentifier"
    let kThumbCellIdentifier  = "kThumbCellIdentifier"
    let kSetCellIdentifier    = "kSetCellIdentifier"
    
    var collectionView:UICollectionView?
    var lblTitle:UILabel?
    var btnSeeAll:UIButton?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        let view = UIView(frame: CGRectMake(0, 0, 320, 30))
//        lblTitle = UILabel(frame: CGRectMake(0, 0, 240, 30))
//        lblTitle?.text = "High..."
//        btnSeeAll = UIButton(frame: CGRectMake(240, 0, 80, 30))
//        btnSeeAll!.titleLabel?.text = "See All>"
//        view.backgroundColor = UIColor.greenColor()
//        view.addSubview(lblTitle!)
//        view.addSubview(btnSeeAll!)
        
        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10)

        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView = UICollectionView(frame: CGRectMake(0, 30, 320, 132), collectionViewLayout: layout)
        collectionView!.registerNib(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kBannerCellIdentifier)
        collectionView!.registerNib(UINib(nibName: "ThumbCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kThumbCellIdentifier)
        collectionView!.registerNib(UINib(nibName: "SetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kSetCellIdentifier)
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.pagingEnabled = true
        collectionView!.backgroundColor = UIColor.whiteColor()
        
        self.contentView.addSubview(collectionView!)
    }
    
    override func layoutSubviews()  {
        super.layoutSubviews()
    
        collectionView!.frame = self.contentView.bounds
        
        let layout = collectionView?.collectionViewLayout as UICollectionViewFlowLayout?
        if collectionView!.tag == 0 {
            layout?.itemSize = CGSizeMake(318, 130)
        } else if collectionView!.tag == 1 || collectionView!.tag == 2 || collectionView!.tag == 3 {
            layout?.itemSize = CGSizeMake(100, 130)
        }
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: protocol<UICollectionViewDataSource, UICollectionViewDelegate>, index: NSInteger) {
        collectionView!.dataSource = dataSourceDelegate
        collectionView!.delegate = dataSourceDelegate
        collectionView!.tag = index
    
        collectionView!.reloadData()
    }
}
