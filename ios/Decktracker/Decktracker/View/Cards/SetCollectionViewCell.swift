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
    @IBOutlet weak var imgLocked: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblSetName.sizeToFit()
//        lblSetName.adjustsFontSizeToFitWidth = true
    }

    func displaySet(setId: String) {
        let path = FileManager.sharedInstance().setPath(setId, small: false)
        var setImage:UIImage?
        
        if path != nil && NSFileManager.defaultManager().fileExistsAtPath(path) {
            setImage = UIImage(contentsOfFile: path)
        } else {
            setImage = UIImage(named: "blank.png")
        }
        
        // resize the image
        if setImage != nil {
            let itemSize = CGSizeMake(setImage!.size.width/2, setImage!.size.height/2)
            imgSet.image = JJJUtil.imageWithImage(setImage, scaledToSize: itemSize);
        }
        
        let dict = Database.sharedInstance().inAppSettingsForSet(setId)
        if dict != nil {
            imgLocked.image = UIImage(named: "locked.png")
        } else {
            imgLocked.image = UIImage(named: "blank.png")
        }
        
        let set = DTSet(forPrimaryKey: setId)
        lblSetName.text = set!.name
    }
}
