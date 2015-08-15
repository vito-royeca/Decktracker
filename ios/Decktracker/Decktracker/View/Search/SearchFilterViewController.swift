//
//  SearchFilterViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 6/9/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class SearchFilterViewController: XLFormViewController {
    
    enum Tags : String {
        case SearchInName    = "searchInName"
        case SearchInText    = "searchInText"
        case SearchInFlavor  = "searchInFlavor"
        case SearchBlack     = "SearchInBlack"
        case SearchBlue      = "searchInBlue"
        case SearchGreen     = "SearchInGreen"
        case SearchRed       = "SearchInRed"
        case SearchWhite     = "searchInWhite"
        case SearchColorless = "SearchInColorless"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    func initializeForm() {
        
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        var manaImage:UIImage?
        var userKey:AnyObject?
        
        form = XLFormDescriptor(title: "Search Filter")
        
        section = XLFormSectionDescriptor.formSectionWithTitle("Search Terms")
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: Tags.SearchInName.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Search In Name")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchInName.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchInName.rawValue)
        }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.SearchInText.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Search In Text")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchInText.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchInText.rawValue)
        }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.SearchInFlavor.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Search In Flavor")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchInFlavor.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchInFlavor.rawValue)
        }
        section.addFormRow(row)
        
        // Search By Mana color
        section = XLFormSectionDescriptor.formSectionWithTitle("Search By Color")
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: Tags.SearchBlack.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Black")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchBlack.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchBlack.rawValue)
        }
        manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/B/32.png");
        row.cellConfig["imageView.image"] = JJJUtil.imageWithImage(manaImage, scaledToSize:CGSize(width: manaImage!.size.width/2, height:manaImage!.size.height/2))
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.SearchBlue.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Blue")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchBlue.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchBlue.rawValue)
        }
        manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/U/32.png");
        row.cellConfig["imageView.image"] = JJJUtil.imageWithImage(manaImage, scaledToSize:CGSize(width: manaImage!.size.width/2, height:manaImage!.size.height/2))
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.SearchGreen.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Green")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchGreen.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchGreen.rawValue)
        }
        manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/G/32.png");
        row.cellConfig["imageView.image"] = JJJUtil.imageWithImage(manaImage, scaledToSize:CGSize(width: manaImage!.size.width/2, height:manaImage!.size.height/2))
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.SearchRed.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Red")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchRed.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchRed.rawValue)
        }
        manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/R/32.png");
        row.cellConfig["imageView.image"] = JJJUtil.imageWithImage(manaImage, scaledToSize:CGSize(width: manaImage!.size.width/2, height:manaImage!.size.height/2))
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.SearchWhite.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "White")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchWhite.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchWhite.rawValue)
        }
        manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/W/32.png");
        row.cellConfig["imageView.image"] = JJJUtil.imageWithImage(manaImage, scaledToSize:CGSize(width: manaImage!.size.width/2, height:manaImage!.size.height/2))
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.SearchColorless.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Colorless")
        userKey = NSUserDefaults.standardUserDefaults().objectForKey(Tags.SearchColorless.rawValue)
        row.value = userKey != nil ? userKey!.boolValue : 1
        row.onChangeBlock = { (oldValue: AnyObject?, newValue: AnyObject?, rowDescriptor: XLFormRowDescriptor?) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(newValue!.boolValue, forKey: Tags.SearchColorless.rawValue)
        }
        manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/Colorless/32.png");
        row.cellConfig["imageView.image"] = JJJUtil.imageWithImage(manaImage, scaledToSize:CGSize(width: manaImage!.size.width/2, height:manaImage!.size.height/2))
        section.addFormRow(row)
        
        self.form = form
    }
}
