//
//  MultilineTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/10/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class MultilineTableViewCell: UITableViewCell {

    var textView:UITextView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textView = UITextView()
        self.addSubview(textView!)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
