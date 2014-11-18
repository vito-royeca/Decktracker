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
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSeeAll: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate:HorizontalScrollTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView!.registerNib(UINib(nibName: "ThumbCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kThumbCellIdentifier)
        collectionView!.registerNib(UINib(nibName: "SetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kSetCellIdentifier)
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
    
    
    @IBAction func seeAllTapped(sender: UIButton) {
        delegate?.seeAll(collectionView.tag)
    }
}
