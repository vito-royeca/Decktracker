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
    var currentCropPath:String?
    
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
        
        currentCropPath = FileManager.sharedInstance().cropPath(self.card)
        imgCrop.image = UIImage(contentsOfFile: currentCropPath!)
        
        FileManager.sharedInstance().downloadCropImage(self.card, immediately:false)
        FileManager.sharedInstance().downloadCardImage(self.card, immediately:false)
        
        // set image
        let dict = Database.sharedInstance().inAppSettingsForSet(card.set)
        if dict != nil {
            imgSet.image = UIImage(named: "locked.png")
            
        } else {
            let path = FileManager.sharedInstance().cardSetPath(card)
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
    }
    
    func loadCropImage(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        let card = dict?["card"] as DTCard
        
        if (self.card == card) {
            let path = FileManager.sharedInstance().cropPath(card)
            
            if path != currentCropPath {
                let hiResImage = UIImage(contentsOfFile: path)
                
                UIView.transitionWithView(imgCrop!,
                    duration:1,
                    options: UIViewAnimationOptions.TransitionCrossDissolve,
                    animations: { self.imgCrop!.image = hiResImage },
                    completion: nil)
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name:kCropDownloadCompleted,  object:nil)
        }
    }
}
