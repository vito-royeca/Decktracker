//
//  PricingTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 17/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import MBProgressHUD

class PricingTableViewCell: UITableViewCell {

    // MARK: Variables
    private var _cardOID: NSManagedObjectID?
    var cardOID : NSManagedObjectID? {
        get {
            return _cardOID
        }
        set (newValue) {
            if (_cardOID != newValue) {
                _cardOID = newValue
                
                displayPricing()
            }
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var lowPriceLabel: UILabel!
    @IBOutlet weak var midPriceLabel: UILabel!
    @IBOutlet weak var highPriceLabel: UILabel!
    @IBOutlet weak var foilPriceLabel: UILabel!
    
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lowPriceLabel.adjustsFontSizeToFitWidth = true
        lowPriceLabel.sizeToFit()
        midPriceLabel.adjustsFontSizeToFitWidth = true
        midPriceLabel.sizeToFit()
        highPriceLabel.adjustsFontSizeToFitWidth = true
        highPriceLabel.sizeToFit()
        foilPriceLabel.adjustsFontSizeToFitWidth = true
        foilPriceLabel.sizeToFit()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom Methods
    func displayPricing() {
        if let _cardOID = _cardOID {
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(_cardOID) as! Card
        
            let completion = { (cardID: String, error: NSError?) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.contentView, animated: true)
                    
                    if let _ = error {
                        self.setNAValues()
                        
                    } else {
                        if let pricing = card.pricing {
                            if let lowPrice = pricing.lowPrice {
                                self.lowPriceLabel.text = "$\(lowPrice.doubleValue)"
                                self.lowPriceLabel.textColor = UIColor.redColor()
                            } else {
                                self.lowPriceLabel.text = "N/A"
                                self.lowPriceLabel.textColor = UIColor.lightGrayColor()
                            }
                            
                            if let midPrice = pricing.midPrice {
                                self.midPriceLabel.text = "$\(midPrice.doubleValue)"
                                self.midPriceLabel.textColor = UIColor.blueColor()
                            } else {
                                self.midPriceLabel.text = "N/A"
                                self.midPriceLabel.textColor = UIColor.lightGrayColor()
                            }
                            
                            if let highPrice = pricing.highPrice {
                                self.highPriceLabel.text = "$\(highPrice.doubleValue)"
                                self.highPriceLabel.textColor = JJJUtil.colorFromHexString("#008000")
                            } else {
                                self.highPriceLabel.text = "N/A"
                                self.highPriceLabel.textColor = UIColor.lightGrayColor()
                            }
                            
                            if let foilPrice = pricing.foilPrice {
                                self.foilPriceLabel.text = "$\(foilPrice.doubleValue)"
                                self.foilPriceLabel.textColor = JJJUtil.colorFromHexString("#998100")
                            } else {
                                self.foilPriceLabel.text = "N/A"
                                self.foilPriceLabel.textColor = UIColor.lightGrayColor()
                            }
                            
                        } else {
                            self.setNAValues()
                        }
                    }
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(contentView, animated: true)
                try TCGPlayerManager.sharedInstance.hiMidLowPrices(card.cardID!, completion: completion)
                
            } catch {
                MBProgressHUD.hideHUDForView(contentView, animated: true)
            }
            
        } else {
            setNAValues()
        }
    }
    
    func setNAValues() {
        lowPriceLabel.text = "N/A"
        lowPriceLabel.textColor = UIColor.lightGrayColor()
        midPriceLabel.text = "N/A"
        midPriceLabel.textColor = UIColor.lightGrayColor()
        highPriceLabel.text = "N/A"
        highPriceLabel.textColor = UIColor.lightGrayColor()
        foilPriceLabel.text = "N/A"
        foilPriceLabel.textColor = UIColor.lightGrayColor()
    }
}
