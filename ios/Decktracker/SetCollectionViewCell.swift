//
//  SetCollectionViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

class SetCollectionViewCell: UICollectionViewCell {

    // MARK: Variables
    private var _setOID: NSManagedObjectID?
    var setOID : NSManagedObjectID? {
        get {
            return _setOID
        }
        set (newValue) {
            if (_setOID != newValue) {
                _setOID = newValue
                
                displaySet()
            }
        }
        
    }
    var formatter:NSDateFormatter?
    
    // MARK: Outlets
    @IBOutlet weak var setImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        formatter = NSDateFormatter()
        formatter!.dateFormat = "YYYY-MM-dd"
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.sizeToFit()
    }

    // MARK: Custom methods
    func displaySet() {
        if let _setOID = _setOID {
            let set = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(_setOID) as! Set
            let sorter = NSSortDescriptor(key: "symbol", ascending: true)
            
            for r in ObjectManager.sharedInstance.findObjects("Rarity", predicate: nil, sorters: [sorter]) {
                if let rarity = r as? Rarity {
                    let path = "\(NSBundle.mainBundle().bundlePath)/images/set/\(set.code!)/\(rarity.symbol!)/48.png"
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(path) {
                        let image = UIImage(contentsOfFile: path)
                        setImage.image = image
                        setImage.contentMode = .ScaleAspectFit
                        break
                    } else {
                        setImage.image = nil
                    }
                }
            }
            
            nameLabel.text = set.name
            countLabel.text = "\(set.numberOfCards!) cards"
            
        } else {
            setImage.image = nil
            nameLabel.text = nil
            countLabel.text = nil
        }
    }
}
