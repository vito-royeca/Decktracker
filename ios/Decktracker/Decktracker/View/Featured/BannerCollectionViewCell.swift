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
    var card:DTCard?
    var planeswalkerType:DTCardType?
    var _pre8thEditionFont:UIFont?
    var _8thEditionFont:UIFont?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        planeswalkerType = DTCardType.MR_findFirstByAttribute("name", withValue:"Planeswalker") as DTCardType?
        _pre8thEditionFont = UIFont(name: "Magic:the Gathering", size:25)
        _8thEditionFont = UIFont(name: "Matrix-Bold", size:25)
        
        self.lblCardName.adjustsFontSizeToFitWidth = true
        lblCardName.shadowOffset = CGSizeMake(1, 1)
    }

    func displayCard(card: DTCard) {
        self.card = card
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCropDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCropImage:",  name:kCropDownloadCompleted, object:nil)
        
        if Database.sharedInstance().isCardModern(card) {
            lblCardName.font = _8thEditionFont;
        
        } else {
            lblCardName.font = _pre8thEditionFont;
        }
        lblCardName.text = self.card?.name
        
        var path = FileManager.sharedInstance().cropPath(self.card)
        var cropImage:UIImage?
        var averageColor:UIColor?

        if path.hasSuffix("cropback.hq.jpg") {
            let cropBackPath = "\(NSBundle.mainBundle().bundlePath)/images/cardback-crop.hq.jpg"
            cropImage = UIImage(contentsOfFile: cropBackPath)
            imgCrop.contentMode = UIViewContentMode.ScaleToFill
        } else {
            cropImage = UIImage(contentsOfFile: path)
            imgCrop.contentMode = UIViewContentMode.ScaleAspectFill
        }
        
        averageColor = cropImage?.averageColor()
        imgCrop.image = cropImage
        lblCardName.shadowColor = cropImage?.patternColor(averageColor)
        lblCardName.textColor = averageColor
        FileManager.sharedInstance().downloadCropImage(self.card, immediately:false)
        FileManager.sharedInstance().downloadCardImage(self.card, immediately:false)
        
        // set image
        path = FileManager.sharedInstance().cardSetPath(card)
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
        let card = dict?["card"] as DTCard
    
        if (self.card == card) {
            let hiResImage = UIImage(contentsOfFile:FileManager.sharedInstance().cropPath(card))
    
            imgCrop.contentMode = UIViewContentMode.ScaleAspectFill
            imgCrop.image = hiResImage
            let average = hiResImage!.averageColor()
            lblCardName.shadowColor = hiResImage!.patternColor(average)
            lblCardName.textColor = average
        }
    }
}
