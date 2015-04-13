//
//  CardListCollectionViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 2/2/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class CardListCollectionViewCell: UICollectionViewCell {

    var lblRank:UILabel?
    var lblBadge:UILabel?
    var imgCard:UIImageView?
    var card:DTCard?
    var currentCardPath:String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)
        
        var dX:CGFloat = 0
        var dY:CGFloat = 0
        var dWidth = frame.size.width
        var dHeight = frame.size.height /*frame.size.height-(frame.size.height/5)*/
        var dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        imgCard = UIImageView(frame: dFrame)
        imgCard!.contentMode = UIViewContentMode.ScaleAspectFit
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
        lblBadge = UILabel(frame: dFrame)
        lblBadge!.textColor = UIColor.whiteColor()
        lblBadge!.font = UIFont.systemFontOfSize(14)
        lblBadge!.textAlignment = NSTextAlignment.Center
        
        contentView.addSubview(imgCard!)
        contentView.addSubview(lblRank!)
        contentView.addSubview(lblBadge!)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func displayCard(card: DTCard) {
        self.card = card
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCardDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCardImage:",  name:kCardDownloadCompleted, object:nil)
        
        // card image
        currentCardPath = FileManager.sharedInstance().cardPath(card)
        self.imgCard!.image = UIImage(contentsOfFile: currentCardPath!)
        FileManager.sharedInstance().downloadCardImage(card, immediately:false)
    }
    
    func loadCardImage(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        let card = dict?["card"] as DTCard
        
        if (self.card == card) {
            let path = FileManager.sharedInstance().cardPath(card)
            
            if path != currentCardPath {
                let hiResImage = UIImage(contentsOfFile: path)
                
                UIView.transitionWithView(imgCard!,
                    duration:1,
                    options: UIViewAnimationOptions.TransitionFlipFromLeft,
                    animations: { self.imgCard!.image = hiResImage },
                    completion: nil)
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name:kCardDownloadCompleted,  object:nil)
        }
    }
    
    func addBadge(rankValue: Int) {
        lblBadge!.text = "\(rankValue)x"
        lblBadge!.layer.backgroundColor = UIColor.redColor().CGColor
        lblBadge!.layer.cornerRadius = lblBadge!.bounds.size.height / 4;
    }
    
    func addRank(rankValue: Int) {
        lblRank!.text = "\(rankValue)"
        lblRank!.layer.backgroundColor = UIColor.whiteColor().CGColor
        lblRank!.layer.cornerRadius = lblRank!.bounds.size.height / 2;
    }
}
