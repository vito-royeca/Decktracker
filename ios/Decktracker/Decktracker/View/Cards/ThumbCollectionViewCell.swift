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
    
    var cardId:String?
    var currentCropPath:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgCrop.layer.cornerRadius = 10.0
        imgCrop.layer.masksToBounds = true
    }

    func displayCard(cardId: String) {
        self.cardId = cardId
        
        let card = DTCard(forPrimaryKey: self.cardId)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCardDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCropImage:",  name:kCardDownloadCompleted, object:nil)
        
        lblCardName.text = card.name
        lblSetName.text = card.set.name
        
        currentCropPath = FileManager.sharedInstance().cropPath(self.cardId)
        imgCrop.image = UIImage(contentsOfFile: currentCropPath!)
        
        FileManager.sharedInstance().downloadCardImage(self.cardId, immediately:false)
        
        // set image
        let dict = Database.sharedInstance().inAppSettingsForSet(card.set.setId)
        if dict != nil {
            imgSet.image = UIImage(named: "locked.png")
            
        } else {
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
}
