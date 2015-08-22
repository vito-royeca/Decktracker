//
//  ThumbCollectionViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/12/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class ThumbCollectionViewCell: UICollectionViewCell {

    let kBannerCellIdentifier  = "kBannerCellIdentifier"
    let kBannerCellWidth       = 95
    let kBannerCellHeight      = 128
    
    var imgCrop: UIImageView?
    var imgSet: UIImageView?
    var lblCardName: UILabel?
    var ratingControl: EDStarRating?
    
    var cardId:String?
    var currentCropPath:String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var dX = CGFloat(4)
        var dY = CGFloat(0)
        var dWidth  = CGFloat(87)
        var dHeight = CGFloat(65)
        var dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        
        imgCrop = UIImageView(frame: dFrame)
        imgCrop!.contentMode = UIViewContentMode.ScaleToFill
        imgCrop!.layer.cornerRadius = 10.0
        imgCrop!.layer.masksToBounds = true
        contentView.addSubview(imgCrop!)
        
        dX = CGFloat(71)
        dY = CGFloat(43)
        dWidth  = CGFloat(24)
        dHeight = CGFloat(24)
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        
        imgSet = UIImageView(frame: dFrame)
        imgSet!.contentMode = UIViewContentMode.Center
        contentView.addSubview(imgSet!)
        
        dX = CGFloat(4)
        dY = CGFloat(69)
        dWidth  = CGFloat(87)
        dHeight = CGFloat(40)
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        
        lblCardName = UILabel(frame: dFrame)
        lblCardName!.font = UIFont.systemFontOfSize(12)
        lblCardName!.numberOfLines = 0
        lblCardName!.adjustsFontSizeToFitWidth = true
        contentView.addSubview(lblCardName!)
        
        dX = CGFloat(0)
        dY = lblCardName!.frame.origin.y + lblCardName!.frame.size.height
        dWidth  = CGFloat(kBannerCellWidth)
        dHeight = CGFloat(16)
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        
        ratingControl = EDStarRating(frame: dFrame)
        ratingControl!.userInteractionEnabled = false
        ratingControl!.starImage = UIImage(named: "star.png")
        ratingControl!.starHighlightedImage = UIImage(named: "starhighlighted.png")
        ratingControl!.maxRating = 5
        ratingControl!.backgroundColor = UIColor.clearColor()
        ratingControl!.displayMode = UInt(EDStarRatingDisplayHalf)
        contentView.addSubview(ratingControl!)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func displayCard(cardId: String) {
        self.cardId = cardId
        let card = DTCard(forPrimaryKey: self.cardId)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kParseSyncDone, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"parseSyncDone:", name: kParseSyncDone, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kCardDownloadCompleted, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"loadCropImage:",  name:kCardDownloadCompleted, object:nil)
        
        lblCardName!.text = card!.name
        currentCropPath = FileManager.sharedInstance().cropPath(self.cardId)
        imgCrop!.image = UIImage(contentsOfFile: currentCropPath!)
        ratingControl!.rating = Float(card!.rating)
        
        FileManager.sharedInstance().downloadCardImage(self.cardId, immediately:false)
        Database.sharedInstance().fetchCardRating(self.cardId)
        
        // set image
        if let dict = Database.sharedInstance().inAppSettingsForSet(card!.set.setId) {
            imgSet!.image = UIImage(named: "locked.png")
            
        } else {
            let path = FileManager.sharedInstance().cardSetPath(self.cardId)
            if let setImage = UIImage(contentsOfFile: path) {
                let itemSize = CGSizeMake(setImage.size.width/2, setImage.size.height/2)
                imgSet!.image = JJJUtil.imageWithImage(setImage, scaledToSize: itemSize)
            
            } else {
                imgSet!.image = nil
            }
        }
    }
    
    func loadCropImage(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        let cardID = dict?["cardId"] as! String
        
        if self.cardId == cardId {
            let path = FileManager.sharedInstance().cropPath(self.cardId)
            
            if path != currentCropPath {
                let hiResImage = UIImage(contentsOfFile: path)
                
                UIView.transitionWithView(imgCrop!,
                    duration:1,
                    options: UIViewAnimationOptions.TransitionCrossDissolve,
                    animations: { self.imgCrop!.image = hiResImage },
                    completion: nil)
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name:kCardDownloadCompleted,  object:nil)
        }
    }
    
    func parseSyncDone(sender: AnyObject)  {
        let dict = sender.userInfo as Dictionary?
        let cardId = dict?["cardId"] as! String
    
        if self.cardId == cardId {
            let card = DTCard(forPrimaryKey: self.cardId)
            ratingControl!.rating = Float(card!.rating)
    
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kParseSyncDone, object: nil)
        }
    }
}
