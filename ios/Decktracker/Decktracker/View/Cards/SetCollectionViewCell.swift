//
//  SetCollectionViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/12/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class SetCollectionViewCell: UICollectionViewCell {

    let kBannerCellIdentifier  = "kBannerCellIdentifier"
    let kBannerCellWidth       = 80
    let kBannerCellHeight      = 128
    
    var imgSet: UIImageView?
    var imgLocked: UIImageView?
    var lblSetName: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var dX = CGFloat(8)
        var dY = CGFloat(0)
        var dWidth  = CGFloat(64)
        var dHeight = CGFloat(64)
        var dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        
        imgSet = UIImageView(frame: dFrame)
        imgSet!.contentMode = UIViewContentMode.Center
        contentView.addSubview(imgSet!)
        
        dY = imgSet!.frame.size.height - 24
        dWidth  = 24
        dHeight = 24
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        
        imgLocked = UIImageView(frame: dFrame)
        imgLocked!.contentMode = UIViewContentMode.ScaleToFill
        contentView.addSubview(imgLocked!)
        
        dX = 0
        dY = imgSet!.frame.origin.y + imgSet!.frame.size.height
        dWidth  = CGFloat(kBannerCellWidth)
        dHeight = CGFloat(64)
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        
        lblSetName = UILabel(frame: dFrame)
        lblSetName!.font = UIFont.systemFontOfSize(12)
        lblSetName!.numberOfLines = 0
        lblSetName!.adjustsFontSizeToFitWidth = true
        contentView.addSubview(lblSetName!)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func displaySet(setId: String) {
        let path = FileManager.sharedInstance().setPath(setId, small: false)
        var setImage:UIImage?
        
        if path != nil && NSFileManager.defaultManager().fileExistsAtPath(path) {
            setImage = UIImage(contentsOfFile: path)
        } else {
            setImage = UIImage(named: "blank.png")
        }
        
        // resize the image
        if setImage != nil {
            let itemSize = CGSizeMake(setImage!.size.width/2, setImage!.size.height/2)
            imgSet!.image = JJJUtil.imageWithImage(setImage, scaledToSize: itemSize);
        }
        
        if let dict = Database.sharedInstance().inAppSettingsForSet(setId) {
            imgLocked!.image = UIImage(named: "locked.png")
        } else {
            imgLocked!.image = UIImage(named: "blank.png")
        }
        
        let set = DTSet(forPrimaryKey: setId)
        lblSetName!.text = set!.name
    }
}
