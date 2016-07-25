//
//  CardSummaryTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 15/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class CardSummaryTableViewCell: UITableViewCell {

    // MARK: Constants
    static let CellHeight = CGFloat(80)
    let preEightEditionFont      = UIFont(name: "Magic:the Gathering", size: 17.0)
    let preEightEditionFontSmall = UIFont(name: "Magic:the Gathering", size: 14.0)
    let eightEditionFont         = UIFont(name: "Matrix-Bold", size: 17.0)
    let eightEditionFontSmall    = UIFont(name: "Matrix-Bold", size: 14.0)
    let magic2015Font            = UIFont(name: "Beleren", size: 17.0)
    let magic2015FontSmall       = UIFont(name: "Beleren", size: 14.0)
    
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
    var cardBackImage:UIImage?
    
    // MARK: Outlets
    @IBOutlet weak var cropImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var castingCostView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var setImage: UIImageView!
    @IBOutlet weak var setLabel: UILabel!

    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardBackImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/cropback.hq.jpg")
        
        cropImage.layer.cornerRadius = 10.0
        cropImage.layer.masksToBounds = true
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.sizeToFit()
        setLabel.adjustsFontSizeToFitWidth = true
        setLabel.sizeToFit()
        
        // removed the star rating: July 25, 2016
//        ratingControl = EDStarRating(frame: ratingView.frame)
//        ratingControl!.userInteractionEnabled = false
//        ratingControl!.starImage = UIImage(named: "starRating")
//        ratingControl!.starHighlightedImage = UIImage(named: "starRatingHighlighted")
//        ratingControl!.maxRating = 5
//        ratingControl!.backgroundColor = UIColor.clearColor()
//        ratingControl!.displayMode = EDStarRatingDisplayHalf
//        ratingView.removeFromSuperview()
//        addSubview(ratingControl!)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom methods
    func displayCard() {
        // remove first
        for v in castingCostView.subviews {
            v.removeFromSuperview()
        }
        
        if let _cardOID = _cardOID {
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(_cardOID) as! Card
            
            if let cropPath = card.cropPath {
                if NSFileManager.defaultManager().fileExistsAtPath(cropPath.path!) {
                    cropImage.image = UIImage(contentsOfFile: cropPath.path!)
                } else {
                    cropImage.image = cardBackImage
                    
                    if let urlPath = card.urlPath {
                        let completedBlock = { (image: UIImage?, data: NSData?, error: NSError?, finished: Bool) -> Void in
                            
                            if let image = image {
                                let croppedImage = self.createCardCropForImage(card, image: image)
                                
                                performUIUpdatesOnMain {
                                    UIView.transitionWithView(self.cropImage, duration: 1.0, options: .TransitionCrossDissolve, animations: {
                                            self.cropImage.image = croppedImage
                                        }, completion: nil)
                                }
                            }
                        }
                        
                        let downloader = SDWebImageDownloader.sharedDownloader()
                        downloader.downloadImageWithURL(urlPath, options: .UseNSURLCache, progress: nil, completed: completedBlock)
                    }
                }
            }
            
            nameLabel.text = card.name
            if let releaseDate = card.set!.releaseDate {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                let m15Date = formatter.dateFromString("2014-07-18")
                
                if releaseDate.compare(m15Date!) == .OrderedSame ||
                    releaseDate.compare(m15Date!) == .OrderedDescending {
                    nameLabel.font = magic2015Font
                    typeLabel.font = magic2015FontSmall
                } else {
                    nameLabel.font = card.modern!.boolValue ? eightEditionFont : preEightEditionFont
                    typeLabel.font = card.modern!.boolValue ? eightEditionFontSmall : preEightEditionFontSmall
                }
            }
            
//            if let typePath = card.typePath {
//                if NSFileManager.defaultManager().fileExistsAtPath(typePath.path!) {
//                    let image = UIImage(contentsOfFile: typePath.path!)
//                    typeImage.image = image
//                    typeImage.contentMode = .ScaleAspectFit
//                } else {
//                    typeImage.image = nil
//                }
//            } else {
//                typeImage.image = nil
//            }
            
            if let type = card.type {
                var text = type.name!
                
                if let power = card.power,
                    let toughness = card.toughness {
                    text = "\(text) (\(power)/\(toughness))"
                    
                } else {
                    if type.name!.hasPrefix("Planeswalker") {
                        text = "\(text) (Loyalty: \(card.loyalty!))"
                    }
                }
                typeLabel.text = text
            } else {
                typeLabel.text = nil
            }
            
            if let rarity = card.rarity {
                let path = "\(NSBundle.mainBundle().bundlePath)/images/set/\(card.set!.code!)/\(rarity.symbol!)/32.png"
                
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    let image = UIImage(contentsOfFile: path)
                    setImage.image = image
                    setImage.contentMode = .ScaleAspectFit
                } else {
                    setImage.image = nil
                }
                
                var text = "\(card.set!.name!)"
                if let number = card.number {
                    text += "\n#\(number) / \(card.set!.numberOfCards!)"
                }
                setLabel.text = text
                
            } else {
                setImage.image = nil
                setLabel.text = nil
            }
            
            // mana cost
            let arrManaImages = card.manaImages
            var dX:CGFloat = 0.0
            var dY:CGFloat = 0.0
            var index = 0
            
            // recalculate the width
            var newWidth = CGFloat(0)
            for dict in arrManaImages {
                if let dWidth = dict["width"] as? NSNumber {
                    newWidth += CGFloat(dWidth.floatValue)
                }
            }
            castingCostView.removeFromSuperview()
            castingCostView.frame = CGRectMake(contentView.frame.size.width-4-newWidth, nameLabel.frame.origin.y, newWidth, castingCostView.frame.size.height)
            addSubview(castingCostView)
            
            // then add the manas
            for dict in arrManaImages {
                if let dWidth = dict["width"] as? NSNumber,
                    let dHeight = dict["height"] as? NSNumber,
                    let path = dict["path"] as? String {
                    
                    let image = UIImage(contentsOfFile: path)
                    dX = contentView.frame.size.width-4-(CGFloat((arrManaImages.count-index)) * CGFloat(dWidth.floatValue))
                    dY = nameLabel.frame.origin.y
                    let manaImage = UIImageView(frame: CGRect(x: dX, y: dY, width: CGFloat(dWidth.floatValue), height: CGFloat(dHeight.floatValue)))
                    manaImage.contentMode = .ScaleAspectFit
                    manaImage.image = image
                    castingCostView.addSubview(manaImage)
                    index += 1
                }
            }
            
        } else {
            cropImage.image = cardBackImage
            nameLabel.text = nil
            nameLabel.font = nil
            setLabel.text = nil
            setImage.image = nil
        }
    }
    
    func createCardCropForImage(card: Card, image: UIImage) -> UIImage? {
        // write the image to disk first
        let path = SDImageCache.sharedImageCache().defaultCachePathForKey(card.urlPath!.path!)
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            let parentPath = NSURL(string: path)!.URLByDeletingLastPathComponent
            if !NSFileManager.defaultManager().fileExistsAtPath(parentPath!.path!) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(parentPath!.path!,
                                                                             withIntermediateDirectories: true,
                                                                             attributes: nil)
                } catch {}
                
            }
            UIImageJPEGRepresentation(image, 1.0)!.writeToFile(path, atomically: true)
        }
        
        // then create a cropped image
        if let cropPath = card.cropPath {
            let width = image.size.width*3/4
            let rect = CGRect(x: (image.size.width-width)/2,
                              y: card.modern!.boolValue ? 45 : 40,
                              width: width,
                              height: width-60)
            
            let imageRef = CGImageCreateWithImageInRect(image.CGImage, rect)
            let croppedImage = UIImage(CGImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
            
            
            // write the cropped image to disk
            let parentPath = cropPath.URLByDeletingLastPathComponent
            if !NSFileManager.defaultManager().fileExistsAtPath(parentPath!.path!) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(parentPath!.path!,
                    withIntermediateDirectories: true,
                    attributes: nil)
                } catch {}
                
            }
            UIImageJPEGRepresentation(croppedImage, 1.0)!.writeToFile(cropPath.path!, atomically: true)
            
            return croppedImage
        }
        
        return nil
    }
}
