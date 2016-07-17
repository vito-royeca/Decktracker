//
//  CardImageTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 16/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class CardImageTableViewCell: UITableViewCell {

    // MARK: Variables
    private var _cardOID: NSManagedObjectID?
    var cardOID : NSManagedObjectID? {
        get {
            return _cardOID
        }
        set (newValue) {
            if (_cardOID != newValue) {
                _cardOID = newValue
                
                displayCard()
            }
        }
    }
    var backgroundImage:UIImage?
    var cardBackImage:UIImage?
    
    // MARK: Outlets
    @IBOutlet weak var cardImage: UIImageView!
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")
        cardBackImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/cardback.hq.jpg")
        cardImage.backgroundColor = UIColor(patternImage: backgroundImage!)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom methods
    func displayCard() {
        if let _cardOID = _cardOID {
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(_cardOID) as! Card
            
            
            if let urlPath = card.urlPath {
//                if let cachedImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(urlPath.path!) {
//                    cardImage.image = cachedImage
//                } else {
//                    cardImage.image = cardBackImage
//                    
//                    let completedBlock = { (image: UIImage?, data: NSData?, error: NSError?, finished: Bool) -> Void in
//                        if let image = image {
//                            
//                            performUIUpdatesOnMain {
//                                UIView.transitionWithView(self.cardImage, duration: 1.0, options: .TransitionFlipFromRight, animations: {
//                                        self.cardImage.image = image
//                                    }, completion: nil)
//                            }
//                        }
//                    }
//                    
//                    let downloader = SDWebImageDownloader.sharedDownloader()
//                    downloader.downloadImageWithURL(urlPath, options: .UseNSURLCache, progress: nil, completed: completedBlock)
//                }
                
                let completionBlock = { (image: UIImage?, error: NSError?, cacheType: SDImageCacheType, imageURL: NSURL?) -> Void in
                    if let image = image {
                        self.cardImage.image = image
                    }
                }
                cardImage.sd_setImageWithURL(urlPath, placeholderImage: cardBackImage, completed: completionBlock)
            }
            
        } else {
            cardImage.image = cardBackImage
        }
    }
}