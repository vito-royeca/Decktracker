//
//  CardImageCollectionViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 8/12/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class CardImageCollectionViewCell: UICollectionViewCell {
    var lblRank:UILabel?
    var lblQuantity:UILabel?
    var imgCard:UIImageView?
    var lblName:UILabel?
    var imgSetIcon:UIImageView?
    var cardId:String?
    var cropped:Bool?
    var showName:Bool?
    var currentCardPath:String?
    var _pre8thEditionFont:UIFont?
    var _8thEditionFont:UIFont?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)
        
        var dX = CGFloat(0)
        var dY = CGFloat(0)
        var dWidth = frame.size.width
        var dHeight = frame.size.height
        var dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        imgCard = UIImageView(frame: dFrame)
        imgCard!.clipsToBounds = true
        
        dX = 0
        dY = 0
        dWidth = 25
        dHeight = 15
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblRank = UILabel(frame: dFrame)
        lblRank!.textColor = UIColor.lightGrayColor()
        lblRank!.font = UIFont.systemFontOfSize(14)
        lblRank!.textAlignment = NSTextAlignment.Center
        
        dX = frame.size.width-25
        dY = 0
        dWidth = 25
        dHeight = 15
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblQuantity = UILabel(frame: dFrame)
        lblQuantity!.textColor = UIColor.whiteColor()
        lblQuantity!.font = UIFont.systemFontOfSize(14)
        lblQuantity!.textAlignment = NSTextAlignment.Center
        
        dX = 5
        dY = frame.size.height-25
        dWidth = (frame.size.width-24)-5
        dHeight = 25
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblName = UILabel(frame: dFrame)
        lblName!.adjustsFontSizeToFitWidth = true
        lblName!.shadowOffset = CGSizeMake(1, 1)
        
        dX = lblName!.frame.origin.x+lblName!.frame.size.width
        dY = frame.size.height-24
        dWidth = 24
        dHeight = 24
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        imgSetIcon = UIImageView(frame: dFrame)
        imgSetIcon!.contentMode = UIViewContentMode.Center
        
//        var planeswalkerType = DTCardType.objectsWithPredicate(NSPredicate(format: "name = %@", "Planeswalker")).firstObject() as! DTCardType?
        _pre8thEditionFont = UIFont(name: "Magic:the Gathering", size:25)
        _8thEditionFont = UIFont(name: "Matrix-Bold", size:25)
        
        contentView.addSubview(imgCard!)
        contentView.addSubview(lblRank!)
        contentView.addSubview(lblQuantity!)
        contentView.addSubview(lblName!)
        contentView.addSubview(imgSetIcon!)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func displayCard(cardId: String, cropped: Bool, showName: Bool, showSetIcon: Bool) {
        self.cardId = cardId
        self.cropped = cropped
        self.showName = showName
        let card = DTCard(forPrimaryKey: cardId)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kCardDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"loadCardImage:",  name:kCardDownloadCompleted, object:nil)
        
        // card image
        currentCardPath = cropped ? FileManager.sharedInstance().cropPath(self.cardId!) : FileManager.sharedInstance().cardPath(self.cardId!)
        self.imgCard!.image = UIImage(contentsOfFile: currentCardPath!)
        FileManager.sharedInstance().downloadCardImage(self.cardId, immediately:false)
        
        if (cropped) {
            if currentCardPath!.hasSuffix("cropback.hq.jpg") {
                self.imgCard!.contentMode = UIViewContentMode.ScaleToFill
            } else {
                self.imgCard!.contentMode = UIViewContentMode.ScaleAspectFill
            }
        } else {
            imgCard!.contentMode = UIViewContentMode.ScaleAspectFit
        }
        
        if showName {
            if card!.modern {
                lblName!.font = _8thEditionFont;
                
            } else {
                lblName!.font = _pre8thEditionFont;
            }
            lblName!.text = card!.name
            
            let averageColor = self.imgCard!.image!.averageColor()
            lblName!.shadowColor = self.imgCard!.image!.patternColor(averageColor)
            lblName!.textColor = averageColor
        }
        
        if showSetIcon {
            let path = FileManager.sharedInstance().cardSetPath(self.cardId)
            
            if let image = UIImage(contentsOfFile: path) {
                let itemSize = CGSizeMake(image.size.width/2, image.size.height/2)
                imgSetIcon!.image = JJJUtil.imageWithImage(image, scaledToSize: itemSize)
                
            } else {
                imgSetIcon!.image = nil
            }
        }
    }
    
    func loadCardImage(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary!
        let cardId = dict["cardId"] as! String
        
        if self.cardId == cardId {
            let path = self.cropped! ? FileManager.sharedInstance().cropPath(self.cardId!) : FileManager.sharedInstance().cardPath(self.cardId!)
            self.imgCard!.contentMode = (self.cropped!) ? UIViewContentMode.ScaleAspectFill : UIViewContentMode.ScaleAspectFit
            
            if path != currentCardPath {
                let hiResImage = UIImage(contentsOfFile: path)
                
                UIView.transitionWithView(imgCard!,
                    duration:1,
                    options: (self.cropped!) ? UIViewAnimationOptions.TransitionNone : UIViewAnimationOptions.TransitionFlipFromLeft,
                    animations: {
                        
                        self.imgCard!.image = hiResImage
                        
                        if self.showName! {
                            let average = hiResImage!.averageColor()
                            self.lblName!.shadowColor = hiResImage!.patternColor(average)
                            self.lblName!.textColor = average
                        }
                    },
                    completion: nil)
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name:kCardDownloadCompleted,  object:nil)
        }
    }
    
    func addQuantity(quantity: Int) {
        lblQuantity!.text = "\(quantity)x"
        lblQuantity!.layer.backgroundColor = UIColor.redColor().CGColor
        lblQuantity!.layer.cornerRadius = lblQuantity!.bounds.size.height / 4;
    }
    
    func addRank(rank: Int) {
        lblRank!.text = "\(rank)"
        lblRank!.layer.backgroundColor = UIColor.whiteColor().CGColor
        lblRank!.layer.cornerRadius = lblRank!.bounds.size.height / 2;
    }
    

}
