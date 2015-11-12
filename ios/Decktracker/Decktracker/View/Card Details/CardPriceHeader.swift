//
//  CardPriceHeader.swift
//  Decktracker
//
//  Created by Jovit Royeca on 7/25/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class CardPriceHeader: UIView {
    var lblLowPrice:UILabel?
    var lblMidPrice:UILabel?
    var lblHighPrice:UILabel?
    var lblFoilPrice:UILabel?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        var dX = CGFloat(0)
        var dY = CGFloat(0)
        let dWidth = frame.width / 4
        let dHeight = frame.height / 2
        
        var label = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(12)
        label.text = "Low"
        addSubview(label)
        
        dX = label.frame.origin.x + label.frame.size.width
        label = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(12)
        label.text = "Mid"
        addSubview(label)
        
        dX = label.frame.origin.x + label.frame.size.width
        label = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(12)
        label.text = "High"
        addSubview(label)
        
        dX = label.frame.origin.x + label.frame.size.width
        label = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(12)
        label.text = "Foil"
        addSubview(label)
        
        dX = CGFloat(0)
        dY = label.frame.origin.y + label.frame.size.height
        lblLowPrice = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        lblLowPrice!.textColor = UIColor.lightGrayColor()
        lblLowPrice!.textAlignment = NSTextAlignment.Center
        lblLowPrice!.adjustsFontSizeToFitWidth = true
        lblLowPrice!.font = UIFont.systemFontOfSize(12)
        lblLowPrice!.text = "N/A"
        addSubview(lblLowPrice!)
        
        dX = lblLowPrice!.frame.origin.x + lblLowPrice!.frame.size.width
        lblMidPrice = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        lblMidPrice!.textColor = UIColor.lightGrayColor()
        lblMidPrice!.textAlignment = NSTextAlignment.Center
        lblMidPrice!.adjustsFontSizeToFitWidth = true
        lblMidPrice!.font = UIFont.systemFontOfSize(12)
        lblMidPrice!.text = "N/A"
        addSubview(lblMidPrice!)
        
        dX = lblMidPrice!.frame.origin.x + lblMidPrice!.frame.size.width
        lblHighPrice = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        lblHighPrice!.textColor = UIColor.lightGrayColor()
        lblHighPrice!.textAlignment = NSTextAlignment.Center
        lblHighPrice!.adjustsFontSizeToFitWidth = true
        lblHighPrice!.font = UIFont.systemFontOfSize(12)
        lblHighPrice!.text = "N/A"
        addSubview(lblHighPrice!)
        
        dX = lblHighPrice!.frame.origin.x + lblHighPrice!.frame.size.width
        lblFoilPrice = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        lblFoilPrice!.textColor = UIColor.lightGrayColor()
        lblFoilPrice!.textAlignment = NSTextAlignment.Center
        lblFoilPrice!.adjustsFontSizeToFitWidth = true
        lblFoilPrice!.font = UIFont.systemFontOfSize(12)
        lblFoilPrice!.text = "N/A"
        addSubview(lblFoilPrice!)
    }
    
    convenience init () {
        self.init(frame:CGRectZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func showCardPricing(cardId: String) {
        let card = DTCard(forPrimaryKey: cardId)
        
        let formatter =  NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = NSNumberFormatterRoundingMode.RoundCeiling
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        
        var price = card!.tcgPlayerLowPrice != 0 ? formatter.stringFromNumber(NSNumber(double:card!.tcgPlayerLowPrice)) : "N/A"
        var color = card!.tcgPlayerLowPrice != 0 ? UIColor.redColor() : UIColor.lightGrayColor()
        lblLowPrice!.text = price
        lblLowPrice!.textColor = color
        
        price = card!.tcgPlayerMidPrice != 0 ? formatter.stringFromNumber(NSNumber(double:card!.tcgPlayerMidPrice)) : "N/A"
        color = card!.tcgPlayerMidPrice != 0 ? UIColor.blueColor() : UIColor.lightGrayColor()
        lblMidPrice!.text = price
        lblMidPrice!.textColor = color
        
        price = card!.tcgPlayerHighPrice != 0 ? formatter.stringFromNumber(NSNumber(double:card!.tcgPlayerHighPrice)) : "N/A"
        color = card!.tcgPlayerHighPrice != 0 ? JJJUtil.colorFromHexString("#008000") : UIColor.lightGrayColor()
        lblHighPrice!.text = price
        lblHighPrice!.textColor = color
        
        price = card!.tcgPlayerFoilPrice != 0 ? formatter.stringFromNumber(NSNumber(double:card!.tcgPlayerFoilPrice)) : "N/A"
        color = card!.tcgPlayerFoilPrice != 0 ? JJJUtil.colorFromHexString("#998100") : UIColor.lightGrayColor()
        lblFoilPrice!.text = price
        lblFoilPrice!.textColor = color
    }
}
