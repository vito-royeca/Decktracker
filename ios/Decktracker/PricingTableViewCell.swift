//
//  PricingTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 17/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

class PricingTableViewCell: UITableViewCell {

    // MARK: Constants
    static let CellHeight = CGFloat(44)
    
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
        lowPriceLabel.text = "$0.0"
        midPriceLabel.text = "$0.0"
        highPriceLabel.text = "$0.0"
        foilPriceLabel.text = "$0.0"
    }
}
