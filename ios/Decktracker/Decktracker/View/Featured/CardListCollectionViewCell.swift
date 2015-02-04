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
    var imgCard:UIImageView?
    var lblLowPrice:UILabel?
    var lblMedianPrice:UILabel?
    var lblHighPrice:UILabel?
    var lblFoilPrice:UILabel?
    var card:DTCard?
    var currentCardPath:String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGrayColor()
        
        var dX:CGFloat = 0
        var dY:CGFloat = 0
        var dWidth = frame.size.width
        var dHeight = frame.size.height /*frame.size.height-(frame.size.height/5)*/
        var dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        imgCard = UIImageView(frame: dFrame)
        imgCard!.contentMode = UIViewContentMode.ScaleAspectFit
        imgCard!.clipsToBounds = true
        contentView.addSubview(imgCard!)
        
        dX = 0
        dY = 0
        dWidth = 25
        dHeight = 15
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblRank = UILabel(frame: dFrame)
        lblRank!.textColor = UIColor.lightGrayColor()
        lblRank!.font = UIFont.systemFontOfSize(14)
        
        
        contentView.addSubview(lblRank!)
        
        /*dX = 0
        dY = imgCard!.frame.size.height
        dWidth = dWidth/4
        dHeight = (frame.size.height-dHeight)/2
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        var lblLabel = UILabel(frame: dFrame)
        lblLabel.text = "Low"
        lblLabel.textColor = UIColor.lightGrayColor()
        lblLabel.font = UIFont.systemFontOfSize(10)
        lblLabel.textAlignment = NSTextAlignment.Right
        contentView.addSubview(lblLabel)
        
        dX = lblLabel.frame.origin.x+lblLabel.frame.size.width
        dY = lblLabel.frame.origin.y
        dWidth = lblLabel.frame.size.width
        dHeight = lblLabel.frame.size.height
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblLabel = UILabel(frame: dFrame)
        lblLabel.text = "Median"
        lblLabel.textColor = UIColor.lightGrayColor()
        lblLabel.font = UIFont.systemFontOfSize(10)
        lblLabel.textAlignment = NSTextAlignment.Right
        contentView.addSubview(lblLabel)
        
        dX = lblLabel.frame.origin.x+lblLabel.frame.size.width
        dY = lblLabel.frame.origin.y
        dWidth = lblLabel.frame.size.width
        dHeight = lblLabel.frame.size.height
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblLabel = UILabel(frame: dFrame)
        lblLabel.text = "High"
        lblLabel.textColor = UIColor.lightGrayColor()
        lblLabel.font = UIFont.systemFontOfSize(10)
        lblLabel.textAlignment = NSTextAlignment.Right
        contentView.addSubview(lblLabel)
        
        dX = lblLabel.frame.origin.x+lblLabel.frame.size.width
        dY = lblLabel.frame.origin.y
        dWidth = lblLabel.frame.size.width
        dHeight = lblLabel.frame.size.height
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblLabel = UILabel(frame: dFrame)
        lblLabel.text = "Foil"
        lblLabel.textColor = UIColor.lightGrayColor()
        lblLabel.font = UIFont.systemFontOfSize(10)
        lblLabel.textAlignment = NSTextAlignment.Right
        contentView.addSubview(lblLabel)
        
        dX = 0
        dY = imgCard!.frame.size.height+lblLabel.frame.size.height
        dWidth = lblLabel.frame.size.width
        dHeight = lblLabel.frame.size.height
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblLowPrice = UILabel(frame: dFrame)
        lblLowPrice!.text = "N/A"
        lblLowPrice!.adjustsFontSizeToFitWidth = true
        lblLowPrice!.textColor = UIColor.lightGrayColor()
        lblLowPrice!.font = UIFont.systemFontOfSize(10)
        lblLowPrice!.textAlignment = NSTextAlignment.Right
        contentView.addSubview(lblLowPrice!)
        
        dX = lblLowPrice!.frame.origin.x+lblLowPrice!.frame.size.width
        dY = lblLowPrice!.frame.origin.y
        dWidth = lblLowPrice!.frame.size.width
        dHeight = lblLowPrice!.frame.size.height
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblMedianPrice = UILabel(frame: dFrame)
        lblMedianPrice!.text = "N/A"
        lblMedianPrice!.adjustsFontSizeToFitWidth = true
        lblMedianPrice!.textColor = UIColor.lightGrayColor()
        lblMedianPrice!.font = UIFont.systemFontOfSize(10)
        lblMedianPrice!.textAlignment = NSTextAlignment.Right
        contentView.addSubview(lblMedianPrice!)
        
        dX = lblMedianPrice!.frame.origin.x+lblMedianPrice!.frame.size.width
        dY = lblMedianPrice!.frame.origin.y
        dWidth = lblMedianPrice!.frame.size.width
        dHeight = lblMedianPrice!.frame.size.height
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblHighPrice = UILabel(frame: dFrame)
        lblHighPrice!.text = "N/A"
        lblHighPrice!.adjustsFontSizeToFitWidth = true
        lblHighPrice!.textColor = UIColor.lightGrayColor()
        lblHighPrice!.font = UIFont.systemFontOfSize(10)
        lblHighPrice!.textAlignment = NSTextAlignment.Right
        contentView.addSubview(lblHighPrice!)
        
        dX = lblHighPrice!.frame.origin.x+lblHighPrice!.frame.size.width
        dY = lblHighPrice!.frame.origin.y
        dWidth = lblHighPrice!.frame.size.width
        dHeight = lblHighPrice!.frame.size.height
        dFrame = CGRectMake(dX, dY, dWidth, dHeight)
        lblFoilPrice = UILabel(frame: dFrame)
        lblFoilPrice!.text = "N/A"
        lblFoilPrice!.adjustsFontSizeToFitWidth = true
        lblFoilPrice!.textColor = UIColor.lightGrayColor()
        lblFoilPrice!.font = UIFont.systemFontOfSize(10)
        lblFoilPrice!.textAlignment = NSTextAlignment.Right
        contentView.addSubview(lblFoilPrice!)*/
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
                    duration:2,
                    options: UIViewAnimationOptions.TransitionFlipFromLeft,
                    animations: { self.imgCard!.image = hiResImage },
                    completion: nil)
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name:kCardDownloadCompleted,  object:nil)
        }
    }
    
    func addRank(rankValue: Int) {
        lblRank!.text = "\(rankValue)"
        lblRank!.layer.backgroundColor = UIColor.whiteColor().CGColor
        lblRank!.layer.cornerRadius = lblRank!.bounds.size.height / 2;
    }
}
