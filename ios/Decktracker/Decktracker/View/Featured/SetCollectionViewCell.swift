//
//  SetCollectionViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/12/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class SetCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgSet: UIImageView!
    @IBOutlet weak var lblSetName: UILabel!
    @IBOutlet weak var lblReleaseDate: UILabel!
    @IBOutlet weak var lblNumberOfCards: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        lblSetName.adjustsFontSizeToFitWidth = true
        lblReleaseDate.adjustsFontSizeToFitWidth = true
        lblNumberOfCards.adjustsFontSizeToFitWidth = true
    }

    func displaySet(set: DTSet) {
        let path = FileManager.sharedInstance().setPath(set, small: false)
        var setImage:UIImage?
        
        if path != nil && NSFileManager.defaultManager().fileExistsAtPath(path) {
            setImage = UIImage(contentsOfFile: path)
        } else {
            setImage = UIImage(named: "blank.png")
        }
        
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
        
        lblSetName.text = set.name
        lblReleaseDate.text = JJJUtil.formatDate(set.releaseDate, withFormat:"YYYY-MM-dd")
        lblNumberOfCards.text = "\(set.numberOfCards) cards"
    }
}
