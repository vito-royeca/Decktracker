//
//  ThumbCollectionViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/12/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class ThumbCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgCrop: UIImageView!
    @IBOutlet weak var lblCardName: UILabel!
    @IBOutlet weak var lblSetName: UILabel!
    @IBOutlet weak var imgSet: UIImageView!
    
    var card:DTCard?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgCrop.layer.cornerRadius = 10.0
        imgCrop.layer.masksToBounds = true
    }

    func displayCard(card: DTCard) {
        self.card = card
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCropDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCropImage:",  name:kCropDownloadCompleted, object:nil)
        
        lblCardName.text = self.card?.name
        lblSetName.text = self.card?.set.name
        
        var path = FileManager.sharedInstance().cropPath(self.card)
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            imgCrop.image = UIImage(named:"blank.png")
        } else {
            imgCrop.image = UIImage(contentsOfFile: path)
        }
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
            
            imgCrop.image = hiResImage
        }
    }
}
