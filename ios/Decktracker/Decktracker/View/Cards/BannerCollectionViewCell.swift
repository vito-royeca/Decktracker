//
//  BannerCollectionViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/12/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblCardName: UILabel!
    @IBOutlet weak var imgCrop: UIImageView!

    @IBOutlet weak var imgSet: UIImageView!
    var cardId:String?
    var planeswalkerType:DTCardType?
    var _pre8thEditionFont:UIFont?
    var _8thEditionFont:UIFont?
    var _currentCropPath:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        planeswalkerType = DTCardType.objectsWithPredicate(NSPredicate(format: "name = %@", "Planeswalker")).firstObject() as! DTCardType?
        _pre8thEditionFont = UIFont(name: "Magic:the Gathering", size:25)
        _8thEditionFont = UIFont(name: "Matrix-Bold", size:25)
        
        self.lblCardName.adjustsFontSizeToFitWidth = true
        lblCardName.shadowOffset = CGSizeMake(1, 1)
    }

    func displayCard(cardId: String) {
        self.cardId = cardId
        let card = DTCard(forPrimaryKey: self.cardId)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCardDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCropImage:",  name:kCardDownloadCompleted, object:nil)
        
        if Database.sharedInstance().isCardModern(self.cardId) {
            lblCardName.font = _8thEditionFont;
        
        } else {
            lblCardName.font = _pre8thEditionFont;
        }
        lblCardName.text = card.name
        
        _currentCropPath = FileManager.sharedInstance().cropPath(self.cardId)
        var cropImage:UIImage?
        var averageColor:UIColor?

        if _currentCropPath!.hasSuffix("cropback.hq.jpg") {
            let cropBackPath = "\(NSBundle.mainBundle().bundlePath)/images/cardback-crop.hq.jpg"
            cropImage = UIImage(contentsOfFile: cropBackPath)
            imgCrop.contentMode = UIViewContentMode.ScaleToFill
        } else {
            cropImage = UIImage(contentsOfFile: _currentCropPath!)
            imgCrop.contentMode = UIViewContentMode.ScaleAspectFill
        }
        
        averageColor = cropImage?.averageColor()
        imgCrop.image = cropImage
        lblCardName.shadowColor = cropImage?.patternColor(averageColor)
        lblCardName.textColor = averageColor
        FileManager.sharedInstance().downloadCardImage(self.cardId, immediately:false)
        
        // set image
        let path = FileManager.sharedInstance().cardSetPath(self.cardId)
        var setImage = UIImage(contentsOfFile: path)
        imgSet.image = setImage
        // resize the image
        if setImage != nil {
            let itemSize = CGSizeMake(setImage!.size.width/2, setImage!.size.height/2)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale)
            let imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height)
            setImage!.drawInRect(imageRect)
            imgSet.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    func loadCropImage(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        let cardId = dict?["cardId"] as! String
        
        if self.cardId == cardId {
            let path = FileManager.sharedInstance().cropPath(self.cardId)
            
            if path != _currentCropPath {
                let hiResImage = UIImage(contentsOfFile: path)
                
                UIView.transitionWithView(imgCrop!,
                    duration:1,
                    options: UIViewAnimationOptions.TransitionNone,
                    animations: {
                        self.imgCrop.contentMode = UIViewContentMode.ScaleAspectFill
                        self.imgCrop!.image = hiResImage
                        
                        let average = hiResImage!.averageColor()
                        self.lblCardName.shadowColor = hiResImage!.patternColor(average)
                        self.lblCardName.textColor = average
                    },
                    completion: nil)
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name:kCardDownloadCompleted,  object:nil)
        }
    }
}
