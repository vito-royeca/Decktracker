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
    var card:Card?
    var _8thEditionSet:Set?
    var planeswalkerType:CardType?
    var pre8thEditionFont:UIFont?
    var _8thEditionFont:UIFont?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        _8thEditionSet = Set.MR_findFirstWithPredicate(NSPredicate(format:"name == %@", "Eighth Edition")) as? Set
        planeswalkerType = CardType.MR_findFirstByAttribute("name", withValue:"Planeswalker") as CardType?
        pre8thEditionFont = UIFont(name: "Magic:the Gathering", size:20)
        _8thEditionFont = UIFont(name: "Matrix-Bold", size:18)
    }

    func displayCard(card: Card) {
        self.card = card
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCropDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCropImage:",  name:kCropDownloadCompleted, object:nil)
        
        lblCardName.text = self.card?.name
        lblCardName.font = pre8thEditionFont
        
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
        let card = dict?["card"] as Card
    
        if (self.card == card) {
            let hiResImage = UIImage(contentsOfFile:FileManager.sharedInstance().cropPath(card))
    
            imgCrop.image = hiResImage
        }
    }
}
