//
//  SubtitleTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {

    // The CGFloat type annotation is necessary for these constants because they are passed as arguments to bridged Objective-C methods,
    // and without making the type explicit these will be inferred to be type Double which is not compatible.
    let kLabelHorizontalInsets: CGFloat = 15.0
    let kLabelVerticalInsets: CGFloat = 10.0
    
    var didSetupConstraints = false
    
    var titleLabel: UILabel = UILabel.newAutoLayoutView()
    var bodyLabel: UILabel = UILabel.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupViews()
    {
        titleLabel.lineBreakMode = .ByTruncatingTail
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Left
        
        bodyLabel.lineBreakMode = .ByTruncatingTail
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .Left
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
    }
    
    override func updateConstraints()
    {
        if !didSetupConstraints {
            // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
            // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
            //      See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
            // contentView.bounds = CGRect(x: 0.0, y: 0.0, width: 99999.0, height: 99999.0)
            
            // Prevent the two UILabels from being compressed below their intrinsic content height
            // FIXME 7-Jun-14 Xcode 6b1: Apple Bug Report rdar://17220525: The UILayoutPriority enum is not compatible with Swift yet!
            // As a temporary workaround, we're using the raw value of UILayoutPriorityRequired = 1000
            UIView.autoSetPriority(1000) {
                self.titleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.bodyLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            }
            
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: kLabelVerticalInsets)
            titleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: kLabelHorizontalInsets)
            titleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: kLabelHorizontalInsets)
            
            // This constraint is an inequality so that if the cell is slightly taller than actually required, extra space will go here
            bodyLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 10.0, relation: .GreaterThanOrEqual)
            
            bodyLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: kLabelHorizontalInsets)
            bodyLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: kLabelHorizontalInsets)
            bodyLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: kLabelVerticalInsets)
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
    
    func updateFonts()
    {
        if let text = bodyLabel.text {
            if count(text) > 0 {
                titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            }
        }
        
        bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
    }
}
