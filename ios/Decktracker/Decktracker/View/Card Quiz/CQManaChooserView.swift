//
//  CQManaChooserView.swift
//  Decktracker
//
//  Created by Jovit Royeca on 4/20/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

protocol CQManaChooserViewDelegate {
    func manaChooserCancelTapped(sender: CQManaChooserView)
    func manaChooserOkTapped(sender: CQManaChooserView, mana: Dictionary<String, NSNumber>)
}

class CQManaChooserView: UIView {

//  MARK: Variables
    var delegate:CQManaChooserViewDelegate?
    
    var manaBlack:Int?
    var manaBlue:Int?
    var manaGreen:Int?
    var manaRed:Int?
    var manaWhite:Int?
    var manaColorless:Int?
    
    var lblTitle:UILabel?
    var arrTxtMana:Array<UILabel>?
    var arrBtnRemoveMana:Array<UILabel>?
    var arrBtnAddMana:Array<UILabel>?
    var btnCancel:UILabel?
    var btnOk:UILabel?

    var userMana:PFObject?
    var cardId:String?
    
//  MARK: Boilerplate
    init(frame: CGRect, title: String, userMana: PFObject, cardId: String) {
        super.init(frame: frame)
        
        self.userMana = userMana
        self.cardId = cardId
        
        setupTitleAndButtons(title)
        setupManaButtons()
        
        let valid = validate()
        btnOk!.userInteractionEnabled = valid ? true : false
        btnOk!.textColor = valid ? CQTheme.kTileTextColor : CQTheme.kTileTextColorX
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

//  MARK: UI code
    func setupManaButtons() {
        arrTxtMana = Array()
        arrBtnRemoveMana = Array()
        arrBtnAddMana = Array()
        
        let card = DTCard(forPrimaryKey: cardId)
        
        let space = CGFloat(10)
        
        var dX = CGFloat(10)
        var dY = 10 + lblTitle!.frame.origin.y + lblTitle!.frame.size.height + space
        let dHeight = (self.frame.size.height - dY - (space*7) - 40) / 6
        let dWidth = self.frame.size.width - dHeight - (space*2)
        
        
        
        for i in 0...5 {
            var dFrame:CGRect?
            var manaImage:UIImage?
            var btnMana:UIImageView?
            var txtManaCount:UILabel?
            var btnRemoveMana:UILabel?
            var btnAddMana:UILabel?
            
            var manaBlack     = 0
            var manaBlue      = 0
            var manaGreen     = 0
            var manaRed       = 0
            var manaWhite     = 0
            var manaColorless = 0
            var currentMana   = 0
            var removeEnabled = true
            var addEnabled    = true
            
            switch i {
            case 0:
                manaColorless = userMana!.objectForKey("colorless")!.integerValue
                if manaColorless > 0 {
                    manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/Colorless/64.png")
                    currentMana += self.castingCostOfCard(card!, forColor: "1")
                    currentMana += self.castingCostOfCard(card!, forColor: "2")
                    currentMana += self.castingCostOfCard(card!, forColor: "3")
                    currentMana += self.castingCostOfCard(card!, forColor: "4")
                    currentMana += self.castingCostOfCard(card!, forColor: "5")
                    currentMana += self.castingCostOfCard(card!, forColor: "6")
                    currentMana += self.castingCostOfCard(card!, forColor: "7")
                    currentMana += self.castingCostOfCard(card!, forColor: "8")
                    currentMana += self.castingCostOfCard(card!, forColor: "9")
                    currentMana += self.castingCostOfCard(card!, forColor: "10")
                    currentMana += self.castingCostOfCard(card!, forColor: "11")
                    currentMana += self.castingCostOfCard(card!, forColor: "12")
                    currentMana += self.castingCostOfCard(card!, forColor: "13")
                    currentMana += self.castingCostOfCard(card!, forColor: "14")
                    currentMana += self.castingCostOfCard(card!, forColor: "15")
                    removeEnabled = currentMana > 0
                    addEnabled = currentMana < manaColorless
                } else {
                    continue
                }
                
            case 1:
                manaBlack = userMana!.objectForKey("black")!.integerValue
                if manaBlack > 0 {
                    manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/B/64.png")
                    currentMana = self.castingCostOfCard(card!, forColor: "B")
                    removeEnabled = currentMana > 0
                    addEnabled = currentMana < manaBlack
                } else {
                    continue
                }
                
            case 2:
                manaBlue = userMana!.objectForKey("blue")!.integerValue
                if manaBlue > 0 {
                    manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/U/64.png")
                    currentMana = self.castingCostOfCard(card!, forColor: "U")
                    removeEnabled = currentMana > 0
                    addEnabled = currentMana < manaBlue
                } else {
                    continue
                }
                
            case 3:
                manaGreen = userMana!.objectForKey("green")!.integerValue
                if manaGreen > 0 {
                    manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/G/64.png")
                    currentMana = self.castingCostOfCard(card!, forColor: "G")
                    removeEnabled = currentMana > 0
                    addEnabled = currentMana < manaGreen
                } else {
                    continue
                }
                
            case 4:
                manaRed = userMana!.objectForKey("red")!.integerValue
                if manaRed > 0 {
                    manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/R/64.png")
                    currentMana = self.castingCostOfCard(card!, forColor: "R")
                    removeEnabled = currentMana > 0
                    addEnabled = currentMana < manaRed
                } else {
                    continue
                }
                
            case 5:
                manaWhite = userMana!.objectForKey("white")!.integerValue
                if manaWhite > 0 {
                    manaImage = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/W/64.png")
                    currentMana = self.castingCostOfCard(card!, forColor: "W")
                    removeEnabled = currentMana > 0
                    addEnabled = currentMana < manaWhite
                } else {
                    continue
                }
                
            default:
                break
            }
            
            dFrame = CGRect(x:dX, y:dY, width:dHeight, height:dHeight)
            btnMana = UIImageView(frame: dFrame!)
            btnMana!.image = manaImage
            addSubview(btnMana!)
            
            dX = btnMana!.frame.origin.x + btnMana!.frame.size.width + space
            dFrame = CGRect(x:dX, y:dY, width:(dWidth-space)/3, height:dHeight)
            txtManaCount = UILabel(frame: dFrame!)
            txtManaCount!.text = "\(currentMana)"
            txtManaCount!.textAlignment = NSTextAlignment.Center
            txtManaCount!.font = CQTheme.kStepperTextFont
            txtManaCount!.adjustsFontSizeToFitWidth = true
            txtManaCount!.textColor = CQTheme.kManaLabelColor
            txtManaCount!.tag = i
            txtManaCount!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
            txtManaCount!.layer.borderWidth = 1
            addSubview(txtManaCount!)
            arrTxtMana!.append(txtManaCount!)
            
            dX = txtManaCount!.frame.origin.x + txtManaCount!.frame.size.width
            dFrame = CGRect(x:dX, y:dY, width:(dWidth-space)/3, height:dHeight)
            btnRemoveMana = UILabel(frame: dFrame!)
            btnRemoveMana!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeTapped:"))
            btnRemoveMana!.userInteractionEnabled = removeEnabled ? true : false
            btnRemoveMana!.text = "-"
            btnRemoveMana!.textAlignment = NSTextAlignment.Center
            btnRemoveMana!.font = CQTheme.kStepperFont
            btnRemoveMana!.textColor = removeEnabled ? CQTheme.kTileTextColor : CQTheme.kTileTextColorX
            btnRemoveMana!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
            btnRemoveMana!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
            btnRemoveMana!.layer.borderWidth = 1
            btnRemoveMana!.tag = i
            addSubview(btnRemoveMana!)
            arrBtnRemoveMana!.append(btnRemoveMana!)
            
            dX = btnRemoveMana!.frame.origin.x + btnRemoveMana!.frame.size.width
            dFrame = CGRect(x:dX, y:dY, width:(dWidth-space)/3, height:dHeight)
            btnAddMana = UILabel(frame: dFrame!)
            btnAddMana!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addTapped:"))
            btnAddMana!.userInteractionEnabled = addEnabled ? true : false
            btnAddMana!.text = "+"
            btnAddMana!.textAlignment = NSTextAlignment.Center
            btnAddMana!.font = CQTheme.kStepperFont
            btnAddMana!.textColor = addEnabled ? CQTheme.kTileTextColor : CQTheme.kTileTextColorX
            btnAddMana!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
            btnAddMana!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
            btnAddMana!.layer.borderWidth = 1
            btnAddMana!.tag = i
            addSubview(btnAddMana!)
            arrBtnAddMana!.append(btnAddMana!)

            dX = CGFloat(10)
            dY += dHeight + space
        }
    }
    
    func setupTitleAndButtons(title: String) {
        self.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)
        self.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
        self.layer.borderWidth = 1
        
        var dX = CGFloat(0)
        var dY = CGFloat(10)
        var dWidth = self.frame.size.width
        var dHeight = CGFloat(20)
        var frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        lblTitle = UILabel(frame: frame)
        lblTitle!.text = title
        lblTitle!.font = CQTheme.kLabelFont
        lblTitle!.adjustsFontSizeToFitWidth = true
        lblTitle!.textColor = CQTheme.kLabelColor
        lblTitle!.textAlignment = NSTextAlignment.Center
        addSubview(lblTitle!)
        
        dY = self.frame.size.height-40
        dWidth = self.frame.size.width / 2
        dHeight = CGFloat(40)
        frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        btnCancel = UILabel(frame: frame)
        btnCancel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "cancelTapped:"))
        btnCancel!.userInteractionEnabled = true
        btnCancel!.text = "Cancel"
        btnCancel!.textAlignment = NSTextAlignment.Center
        btnCancel!.font = CQTheme.kManaLabelFont
        btnCancel!.textColor = CQTheme.kTileTextColor
        btnCancel!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
        btnCancel!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnCancel!.layer.borderWidth = 1
        addSubview(btnCancel!)
        
        dX = btnCancel!.frame.origin.x + btnCancel!.frame.size.width
        frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        btnOk = UILabel(frame: frame)
        btnOk!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "okTapped:"))
        btnOk!.userInteractionEnabled = true
        btnOk!.text = "Ok"
        btnOk!.textAlignment = NSTextAlignment.Center
        btnOk!.font = CQTheme.kManaLabelFont
        btnOk!.textColor = CQTheme.kTileTextColor
        btnOk!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
        btnOk!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnOk!.layer.borderWidth = 1
        addSubview(btnOk!)
    }
    
//  MARK: Event handlers
    func removeTapped(sender: UITapGestureRecognizer) {
        let button = sender.view as! UILabel
        
        for txt in arrTxtMana! {
            if txt.tag == button.tag {
                var mana = Int(txt.text!)
                mana! -= 1
                txt.text = "\(mana)"
                
                if mana <= 0 {
                    for btn in arrBtnRemoveMana! {
                        if btn.tag == txt.tag {
                            btn.textColor = CQTheme.kTileTextColorX
                            btn.userInteractionEnabled = false
                            break
                        }
                    }
                }
                
                // enable if mana is less than userMana
                for btn in arrBtnAddMana! {
                    if btn.tag == txt.tag {
                        switch txt.tag {
                        case 0:
                            if mana < userMana!.objectForKey("colorless")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColor
                                btn.userInteractionEnabled = true
                            }
                        case 1:
                            if mana < userMana!.objectForKey("black")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColor
                                btn.userInteractionEnabled = true
                            }
                        case 2:
                            if mana < userMana!.objectForKey("blue")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColor
                                btn.userInteractionEnabled = true
                            }
                        case 3:
                            if mana < userMana!.objectForKey("green")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColor
                                btn.userInteractionEnabled = true
                            }
                        case 4:
                            if mana < userMana!.objectForKey("red")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColor
                                btn.userInteractionEnabled = true
                            }
                        case 5:
                            if mana < userMana!.objectForKey("white")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColor
                                btn.userInteractionEnabled = true
                            }
                        default:
                            break
                        }
                        break
                    }
                }
                
                break
            }
        }
        
        let valid = validate()
        btnOk!.userInteractionEnabled = valid ? true : false
        btnOk!.textColor = valid ? CQTheme.kTileTextColor : CQTheme.kTileTextColorX
    }
    
    func addTapped(sender: UITapGestureRecognizer) {
        let button = sender.view as! UILabel
        
        for txt in arrTxtMana! {
            if txt.tag == button.tag {
                var mana = Int(txt.text!)
                mana! += 1
                txt.text = "\(mana)"
                
                if mana > 0 {
                    for btn in arrBtnRemoveMana! {
                        if btn.tag == txt.tag {
                            btn.textColor = CQTheme.kTileTextColor
                            btn.userInteractionEnabled = true
                            break
                        }
                    }
                }
                
                // disable if mana is equal to userMana
                for btn in arrBtnAddMana! {
                    if btn.tag == txt.tag {
                        switch txt.tag {
                        case 0:
                            if mana >= userMana!.objectForKey("colorless")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColorX
                                btn.userInteractionEnabled = false
                            }
                        case 1:
                            if mana >= userMana!.objectForKey("black")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColorX
                                btn.userInteractionEnabled = false
                            }
                        case 2:
                            if mana >= userMana!.objectForKey("blue")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColorX
                                btn.userInteractionEnabled = false
                            }
                        case 3:
                            if mana >= userMana!.objectForKey("green")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColorX
                                btn.userInteractionEnabled = false
                            }
                        case 4:
                            if mana >= userMana!.objectForKey("red")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColorX
                                btn.userInteractionEnabled = false
                            }
                        case 5:
                            if mana >= userMana!.objectForKey("white")!.integerValue {
                                btn.textColor = CQTheme.kTileTextColorX
                                btn.userInteractionEnabled = false
                            }
                        default:
                            break
                        }
                        break
                    }
                }
                
                break
            }
        }
        
        let valid = validate()
        btnOk!.userInteractionEnabled = valid ? true : false
        btnOk!.textColor = valid ? CQTheme.kTileTextColor : CQTheme.kTileTextColorX
    }
    
    func cancelTapped(sender: AnyObject?) {
        delegate?.manaChooserCancelTapped(self)
    }
    
    func okTapped(sender: AnyObject?) {
        delegate?.manaChooserOkTapped(self, mana:manaPaid())
    }
    
//  MARK: Logic code
    func manaPaid() -> Dictionary<String, NSNumber> {
        var dict = Dictionary<String, NSNumber>()
        var totalCMC = 0
        
        for txt in arrTxtMana! {
            let mana = Int(txt.text!)
            totalCMC += mana!
            
            switch txt.tag {
            case 0:
                dict["colorless"] = NSNumber(integer: mana!)
            case 1:
                dict["black"] = NSNumber(integer: mana!)
            case 2:
                dict["blue"] = NSNumber(integer: mana!)
            case 3:
                dict["green"] = NSNumber(integer: mana!)
            case 4:
                dict["red"] = NSNumber(integer: mana!)
            case 5:
                dict["white"] = NSNumber(integer: mana!)
            default:
                break
            }
        }
        dict["totalCMC"] = NSNumber(integer: totalCMC)
        
        return dict
    }
    
    func castingCostOfCard(card: DTCard, forColor: String) -> Int {
        var castingCost = 0
        
        let kardId = card.cardId
        for dict in FileManager.sharedInstance().manaImagesForCard(kardId) as! [NSDictionary] {
            let symbol = dict["symbol"] as! String
            
            if symbol == forColor {
                if symbol == "1" ||
                   symbol == "2" ||
                   symbol == "3" ||
                   symbol == "4" ||
                   symbol == "5" ||
                   symbol == "6" ||
                   symbol == "7" ||
                   symbol == "8" ||
                   symbol == "9" ||
                   symbol == "10" ||
                   symbol == "11" ||
                   symbol == "12" ||
                   symbol == "13" ||
                   symbol == "14" ||
                   symbol == "15" {
                
                    castingCost += Int(symbol)!
                    
                } else {
                    castingCost++
                }
            }
        }
        
        return castingCost
    }
    
    func validate() -> Bool {
        let card = DTCard(forPrimaryKey: cardId)
        var mana = manaPaid()
        var colorless = 0
        
        if card!.cmc != mana["totalCMC"]!.floatValue {
            return false
        }
    
        for (k,v) in mana {
            if k == "totalCMC" {
                continue
            } else if k == "black" {
                let cc = castingCostOfCard(card!, forColor: "B")
                if v.integerValue < cc {
                    return false
                } else {
                    colorless += (v.integerValue - cc)
                }
            } else if k == "blue" {
                let cc = castingCostOfCard(card!, forColor: "U")
                if v.integerValue < cc {
                    return false
                } else {
                    colorless += (v.integerValue - cc)
                }
            } else if k == "green" {
                let cc = castingCostOfCard(card!, forColor: "G")
                if v.integerValue < cc {
                    return false
                } else {
                    colorless += (v.integerValue - cc)
                }
            } else if k == "red" {
                let cc = castingCostOfCard(card!, forColor: "R")
                if v.integerValue < cc {
                    return false
                } else {
                    colorless += (v.integerValue - cc)
                }
            } else if k == "white" {
                let cc = castingCostOfCard(card!, forColor: "W")
                if v.integerValue < cc {
                    return false
                } else {
                    colorless += (v.integerValue - cc)
                }
            } else if k == "colorless" {
                let cc = castingCostOfCard(card!, forColor: "\(v)")
                colorless += cc
            }
        }
        
        if colorless < castingCostOfCard(card!, forColor: "\(colorless)") {
            return false
        }
        
        return true
    }
}
