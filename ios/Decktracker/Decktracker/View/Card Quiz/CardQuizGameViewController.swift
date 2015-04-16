//
//  CardQuizGameViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 1/14/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class CardQuizGameViewController: UIViewController, MBProgressHUDDelegate, InAppPurchaseViewControllerDelegate {

//  MARK: Variables
    var lblBlack:UILabel?
    var lblBlue:UILabel?
    var lblGreen:UILabel?
    var lblRed:UILabel?
    var lblWhite:UILabel?
    var lblColorless:UILabel?
    
    var manaBlack     = 0
    var manaBlue      = 0
    var manaGreen     = 0
    var manaRed       = 0
    var manaWhite     = 0
    var manaColorless = 0
    
    var lblCastingCost:UILabel?
    var viewCastingCost:UIView?
    var viewImage:UIImageView?
    var btnHelp:UILabel?
    var btnBuy:UILabel?
    var btnCast:UILabel?
    var btnNextCard:UILabel?
    var arrAnswers:Array<Array<UILabel>>?
    var arrQuizzes:[UILabel]?
    var cards:Array<DTCard>?
    var currentCropPath:String?
    var currentCardPath:String?
    var bCardAnswered = false
    
    var predicate:NSPredicate?
    var userMana:PFObject?
    var gameType:CQGameType?
    
//  MARK: Boilerplate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        hidesBottomBarWhenPushed = true
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kParseUserManaDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"fetchUserManaDone:",  name:kParseUserManaDone, object:nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name:kCardDownloadCompleted,  object:nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:"loadCardImage:",  name:kCardDownloadCompleted, object:nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name:kCardDownloadCompleted,  object:nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:"loadCropImage:",  name:kCardDownloadCompleted, object:nil)
        
        var format:String?
        var formatEx1:String?
        var formatEx2:String?
        
        switch gameType! {
        case .Easy:
            format = "Standard"
            formatEx1 = "Modern"
            formatEx2 = "Vintage"
        case .Moderate:
            format = "Modern"
            formatEx1 = "Standard"
            formatEx2 = "Vintage"
        case .Hard:
            format = "Vintage"
            formatEx1 = "Standard"
            formatEx2 = "Modern"
        }
        
        let predicate1 = NSPredicate(format: "ANY legalities.format.name IN %@ AND NOT (ANY legalities.format.name IN %@)", [format!], [formatEx1!, formatEx2!])
        let predicate2 = NSPredicate(format: "cmc >= 1 AND cmc <= 15 AND name MATCHES %@", "^.{0,20}")
        self.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([predicate1, predicate2])
        
        cards = Array()
        for i in 0...kCQMaxCurrentCards {
            cards!.append(self.generateRandomCard())
        }
        
        setupManaPoints()
        setupImageView()
        setupFunctionButtons()
        displayQuiz()
        updateManaPool()
        
        self.navigationItem.title = "Card Quiz"
        self.view.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: self.navigationItem.title)
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
//  MARK: UI Setup Code
    func setupManaPoints() {
        let manaWidth = (self.view.frame.size.width-10)/6
        let manaImageWidth = CGFloat(16)
        let manaImageHeight = CGFloat(16)
        let manaLabelWidth = manaWidth-manaImageWidth
        let manaLabelHeight = manaImageHeight+2
        
        var dX:CGFloat = 10
        var dY:CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height+5
        var frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        var imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/B/32.png")
        self.view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaLabelHeight)
        lblBlack = UILabel(frame: frame)
        lblBlack!.text = " 0"
        lblBlack!.font = CQTheme.kManaLabelFont
        lblBlack!.adjustsFontSizeToFitWidth = true
        lblBlack!.textColor = CQTheme.kManaLabelColor
        self.view.addSubview(lblBlack!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/U/32.png")
        self.view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaLabelHeight)
        lblBlue = UILabel(frame: frame)
        lblBlue!.text = " 0"
        lblBlue!.font = CQTheme.kManaLabelFont
        lblBlue!.adjustsFontSizeToFitWidth = true
        lblBlue!.textColor = CQTheme.kManaLabelColor
        self.view.addSubview(lblBlue!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/G/32.png")
        self.view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaLabelHeight)
        lblGreen = UILabel(frame: frame)
        lblGreen!.text = " 0"
        lblGreen!.font = CQTheme.kManaLabelFont
        lblGreen!.adjustsFontSizeToFitWidth = true
        lblGreen!.textColor = CQTheme.kManaLabelColor
        self.view.addSubview(lblGreen!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/R/32.png")
        self.view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaLabelHeight)
        lblRed = UILabel(frame: frame)
        lblRed!.text = " 0"
        lblRed!.font = CQTheme.kManaLabelFont
        lblRed!.adjustsFontSizeToFitWidth = true
        lblRed!.textColor = CQTheme.kManaLabelColor
        self.view.addSubview(lblRed!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/W/32.png")
        self.view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaLabelHeight)
        lblWhite = UILabel(frame: frame)
        lblWhite!.text = " 0"
        lblWhite!.font = CQTheme.kManaLabelFont
        lblWhite!.adjustsFontSizeToFitWidth = true
        lblWhite!.textColor = CQTheme.kManaLabelColor
        self.view.addSubview(lblWhite!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/Colorless/32.png")
        self.view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaLabelHeight)
        lblColorless = UILabel(frame: frame)
        lblColorless!.text = " 0"
        lblColorless!.font = CQTheme.kManaLabelFont
        lblColorless!.adjustsFontSizeToFitWidth = true
        lblColorless!.textColor = CQTheme.kManaLabelColor
        self.view.addSubview(lblColorless!)
    }
    
    func setupImageView() {
        var dWidth = self.view.frame.size.width
        var dX = CGFloat(0)
        var dY = UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height
        var dHeight = self.view.frame.height - dY - 120
        var frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        let circleImage = UIImageView(frame: frame)
        circleImage.contentMode = UIViewContentMode.ScaleAspectFill
        circleImage.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Card_Circles.png")
        self.view.addSubview(circleImage)
        
        dWidth = self.view.frame.size.width * 0.70
        dX = (self.view.frame.size.width - dWidth) / 2
        dY += 40
        dHeight = CGFloat(16)
        frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        viewCastingCost = UIView(frame: frame)
        self.view.addSubview(viewCastingCost!)
        
        dY = frame.origin.y + frame.size.height + 10
        dHeight = dWidth - 20
        frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        viewImage = UIImageView(frame: frame)
        viewImage!.contentMode = UIViewContentMode.ScaleAspectFill//Fit
        self.view.addSubview(viewImage!)
    }
    
    func setupFunctionButtons() {
        var dX = CGFloat(0)
        var dY = self.view.frame.height - 120
        var dWidth = self.view.frame.size.width/3
        var dHeight = CGFloat(40)
        var dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        
        // draw the ask button
        btnHelp = UILabel(frame: dFrame)
        btnHelp!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "helpTapped:"))
        btnHelp!.userInteractionEnabled = true
        btnHelp!.text = "Help"
        btnHelp!.textAlignment = NSTextAlignment.Center
        btnHelp!.font = CQTheme.kManaLabelFont
        btnHelp!.textColor = CQTheme.kTileTextColor
        btnHelp!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
        btnHelp!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnHelp!.layer.borderWidth = 1
        self.view.addSubview(btnHelp!)
        
        // draw the buy button
        dX = dFrame.origin.x + dFrame.size.width
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnBuy = UILabel(frame: dFrame)
        btnBuy!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "buyTapped:"))
        btnBuy!.userInteractionEnabled = true
        btnBuy!.text = "Buy Mana"
        btnBuy!.textAlignment = NSTextAlignment.Center
        btnBuy!.font = CQTheme.kManaLabelFont
        btnBuy!.textColor = CQTheme.kTileTextColor
        btnBuy!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
        btnBuy!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnBuy!.layer.borderWidth = 1
        self.view.addSubview(btnBuy!)
        
        // draw the cast button
        dX = dFrame.origin.x + dFrame.size.width
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnCast = UILabel(frame: dFrame)
        btnCast!.userInteractionEnabled = false
        btnCast!.text = "Cast"
        btnCast!.textAlignment = NSTextAlignment.Center
        btnCast!.font = CQTheme.kManaLabelFont
        btnCast!.textColor = CQTheme.kTileTextColorX
        btnCast!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
        btnCast!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnCast!.layer.borderWidth = 1
        self.view.addSubview(btnCast!)
        
        updateManaPool()
    }

    func updateManaPool() {
        if let mana = userMana {
            manaBlack     = mana["black"]!.integerValue
            manaBlue      = mana["blue"]!.integerValue
            manaGreen     = mana["green"]!.integerValue
            manaRed       = mana["red"]!.integerValue
            manaWhite     = mana["white"]!.integerValue
            manaColorless = mana["colorless"]!.integerValue
        }
        
        lblBlack!.text     = " \(manaBlack)"
        lblBlue!.text      = " \(manaBlue)"
        lblGreen!.text     = " \(manaGreen)"
        lblRed!.text       = " \(manaRed)"
        lblWhite!.text     = " \(manaWhite)"
        lblColorless!.text = " \(manaColorless)"
        
        if canCastCard() && btnCast != nil {
            if let recognizers = btnCast!.gestureRecognizers {
                for recognizer in recognizers {
                    btnCast!.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
                }
            }
            btnCast!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "castTapped:"))
            btnCast!.userInteractionEnabled = true
            btnCast!.textColor = CQTheme.kTileTextColor
        }
    }

    func displayQuiz() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kCardDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"loadCropImage:",  name:kCardDownloadCompleted, object:nil)
        
        // draw the mana cost
        let manaImages = FileManager.sharedInstance().manaImagesForCard(cards!.first) as! [NSDictionary]
        var dX = CGFloat(0)
        var dY = CGFloat(0)
        var index = 0
        var dWidth = viewCastingCost!.frame.size.width - CGFloat(manaImages.count * 16)
        var dHeight = CGFloat(20)
        var dFrame:CGRect?
        lblCastingCost = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        lblCastingCost!.text = "Casting Cost: "
        lblCastingCost!.font = CQTheme.kLabelFont
        lblCastingCost!.adjustsFontSizeToFitWidth = true
        lblCastingCost!.textColor = CQTheme.kLabelColor
        viewCastingCost!.addSubview(lblCastingCost!)
        for dict in manaImages {
            dWidth = CGFloat((dict["width"] as! NSNumber).floatValue)
            dHeight = CGFloat((dict["height"] as! NSNumber).floatValue)
            let path = dict["path"] as! String
            dX = viewCastingCost!.frame.size.width - (CGFloat(manaImages.count-index) * dWidth)
            
            dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
            let imgMana = UIImageView(frame: dFrame!)
            
            imgMana.image = UIImage(contentsOfFile: path)
            viewCastingCost!.addSubview(imgMana)
            index++
        }
        
        // load the image
        currentCropPath = FileManager.sharedInstance().cropPath(cards!.first)
        println("\(cards!.first!.name)")
        viewImage!.image = UIImage(contentsOfFile: currentCropPath!)
        FileManager.sharedInstance().downloadCardImage(cards!.first, immediately:true)
        
        // tokenize the answer
        arrAnswers = Array<Array<UILabel>>()
        var lines = [String]()
        for word in cards!.first!.name.componentsSeparatedByString(" ") {
            var line = lines.last != nil ? lines.last : word
            
            if word == line {
                lines.append(word)
                
            } else {
                if (count(line!) + count(word) + 1) <= 12 {
                    lines.removeLast()
                    line = line! + " " + word
                    lines.append(line!)
                } else {
                    lines.append(word)
                }
            }
        }
        
        // draw the answer view
        index = 0
        dY = self.viewImage!.frame.origin.y + self.viewImage!.frame.size.height + 10
        for line in lines {
            var arr = Array<UILabel>()
            
            dWidth = self.view.frame.size.width/12
            dHeight = 30
            dX = (self.view.frame.width - (dWidth*CGFloat(count(line))))/2
            for character in line {
                dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
                let label = UILabel(frame: dFrame!)
                
                if character != " " {
                    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "answerActivated:"))
                    label.userInteractionEnabled = true
                    label.text = "*"
                    label.textAlignment = NSTextAlignment.Center
                    label.font = CQTheme.kTileAnswerFont
                    label.textColor = CQTheme.kTileTextColor
                    label.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
                    label.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
                    label.layer.borderWidth = 1
                    label.tag = index
                } else {
                    label.text = " "
                }
                index++
                
                arr.append(label)
                self.view.addSubview(label)
                dX += dWidth
            }
            arrAnswers!.append(arr)
            dY += dHeight
            index++
        }
        
        // draw the quiz
        let quiz = self.quizForCard(cards!.first!)
        index = 0
        arrQuizzes = Array()
        dWidth = self.view.frame.size.width/10
        dHeight = 40
        dFrame = btnCast!.frame
        for i in 0...19 {
            if i%10 == 0 {
                dX = 0
                dY = dFrame!.origin.y + dFrame!.size.height
            }
            dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
            
            var text:String?
            if i <= count(quiz)-1 {
                let quizIndex = advance(quiz.startIndex, i)
                text = String(quiz[quizIndex])
            }
            
            let label = UILabel(frame: dFrame!)
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "quizActivated:"))
            label.userInteractionEnabled = true
            label.text = text != nil ? text : " "
            label.textAlignment = NSTextAlignment.Center
            label.font = CQTheme.kTileQuizFont
            label.textColor = CQTheme.kTileTextColor
            label.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
            label.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
            label.layer.borderWidth = 1
            label.tag = index
            index++
            arrQuizzes!.append(label)
            self.view.addSubview(label)
            
            dX += dFrame!.size.width
        }
    }
    
    func displayAnswer() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kCardDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"loadCardImage:",  name:kCardDownloadCompleted, object:nil)
        
        var dWidth = self.view.frame.size.width * 0.80
        var dX = (self.view.frame.size.width - dWidth) / 2
        var dY = UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height + 40
        var dHeight = self.view.frame.height - 120
        
        var viewImageFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        var btnNextCardFrame = CGRect(x: btnBuy!.frame.origin.x, y: btnBuy!.frame.origin.y+80, width: btnBuy!.frame.size.width, height: btnBuy!.frame.size.height)
        
        // clean up
        viewImage!.removeFromSuperview()
        if arrAnswers != nil {
            for arr in arrAnswers! {
                for label in arr {
                    label.removeFromSuperview()
                }
            }
        }
        btnHelp!.removeFromSuperview()
        btnBuy!.removeFromSuperview()
        btnCast!.removeFromSuperview()
        if arrQuizzes != nil {
            for label in arrQuizzes! {
                label.removeFromSuperview()
            }
        }
        lblCastingCost!.text = "Added To Your Mana Pool: "

        // load the full card image
        viewImage = UIImageView(frame: viewImageFrame)
        viewImage!.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(viewImage!)
        currentCardPath = FileManager.sharedInstance().cardPath(cards!.first)
        viewImage!.image = UIImage(contentsOfFile: currentCardPath!)
        FileManager.sharedInstance().downloadCardImage(cards!.first, immediately:true)
        
        // draw the next card button
        btnNextCard = UILabel(frame: btnNextCardFrame)
        btnNextCard!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "nextCardTapped:"))
        btnNextCard!.userInteractionEnabled = true
        btnNextCard!.text = "Next Card"
        btnNextCard!.textAlignment = NSTextAlignment.Center
        btnNextCard!.font = CQTheme.kManaLabelFont
        btnNextCard!.textColor = CQTheme.kTileTextColor
        btnNextCard!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
        btnNextCard!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnNextCard!.layer.borderWidth = 1
        self.view.addSubview(btnNextCard!)
        
        // update the mana pool
        for dict in FileManager.sharedInstance().manaImagesForCard(cards!.first) as! [NSDictionary] {
            let symbol = dict["symbol"] as! String
            
            if symbol == "B" {
                manaBlack++
            } else if symbol == "U" {
                manaBlue++
            } else if symbol == "G" {
                manaGreen++
            } else if symbol == "R" {
                manaRed++
            } else if symbol == "W" {
                manaWhite++
            } else if symbol == "1" {
                manaColorless += 1
            } else if symbol == "2" {
                manaColorless += 2
            } else if symbol == "3" {
                manaColorless += 3
            } else if symbol == "4" {
                manaColorless += 4
            } else if symbol == "5" {
                manaColorless += 5
            } else if symbol == "6" {
                manaColorless += 6
            } else if symbol == "7" {
                manaColorless += 7
            } else if symbol == "8" {
                manaColorless += 8
            } else if symbol == "9" {
                manaColorless += 9
            } else if symbol == "10" {
                manaColorless += 10
            } else if symbol == "11" {
                manaColorless += 11
            } else if symbol == "12" {
                manaColorless += 12
            } else if symbol == "13" {
                manaColorless += 13
            } else if symbol == "14" {
                manaColorless += 14
            } else if symbol == "15" {
                manaColorless += 15
            }
        }

        lblBlack!.text     = " \(manaBlack)"
        lblBlue!.text      = " \(manaBlue)"
        lblGreen!.text     = " \(manaGreen)"
        lblRed!.text       = " \(manaRed)"
        lblWhite!.text     = " \(manaWhite)"
        lblColorless!.text = " \(manaColorless)"
        
        self.saveMana()

        // remove first and and append new one
        var key:String?
        switch gameType! {
        case .Easy:
            key = kCQEasyCurrentCard
        case .Moderate:
            key = kCQModerateCurrentCard
        case .Hard:
            key = kCQHardCurrentCard
        }
        cards!.removeAtIndex(0)
        cards!.append(self.generateRandomCard())
        let value = cards!.first!.set.code + "_" + cards!.first!.number
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key!)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

//  MARK: Logic Code
    func generateRandomCard() -> DTCard {
        var key:String?
        var value:String?
        
        switch gameType! {
        case .Easy:
            if let v = NSUserDefaults.standardUserDefaults().stringForKey(kCQEasyCurrentCard) {
                value = v
            } else {
                key = kCQEasyCurrentCard
            }
            
        case .Moderate:
            if let v = NSUserDefaults.standardUserDefaults().stringForKey(kCQModerateCurrentCard) {
                value = v
            } else {
                key = kCQModerateCurrentCard
            }
            
        case .Hard:
            if let v = NSUserDefaults.standardUserDefaults().stringForKey(kCQHardCurrentCard) {
                value = v
            } else {
                key = kCQHardCurrentCard
            }
        }
        
        if value != nil && cards!.count == 0 {
            let array = split(value!) {$0 == "_"}
            let code = array[0]
            let number = array[1]
            let card = DTCard.MR_findFirstWithPredicate(NSPredicate(format: "set.code = %@ AND number = %@", code, number)) as! DTCard
            FileManager.sharedInstance().downloadCardImage(card, immediately:false)
            
            return card
            
        } else {
            let xcards = Database.sharedInstance().fetchRandomCards(1, withPredicate: self.predicate, includeInAppPurchase: true)
            let card = xcards.first as! DTCard
            let value = card.set.code + "_" + card.number
            
            if cards!.count == 0 {
                NSUserDefaults.standardUserDefaults().setObject(value, forKey: key!)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            
            return card
        }
    }

    func saveMana() {
        let totalCMC = manaBlack +
            manaBlue +
            manaGreen +
            manaRed +
            manaWhite +
        manaColorless;
        
        userMana!["black"]     = NSNumber(integer: manaBlack)
        userMana!["blue"]      = NSNumber(integer: manaBlue)
        userMana!["green"]     = NSNumber(integer: manaGreen)
        userMana!["red"]       = NSNumber(integer: manaRed)
        userMana!["white"]     = NSNumber(integer: manaWhite)
        userMana!["colorless"] = NSNumber(integer: manaColorless)
        userMana!["totalCMC"]  = NSNumber(integer: totalCMC)
        
        Database.sharedInstance().saveUserMana(userMana!)
    }
    
    func loadCropImage(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        let card = dict?["card"] as! DTCard
        
        if (cards!.first == card) {
            let path = FileManager.sharedInstance().cropPath(card)
            
            if path != currentCropPath {
                let hiResImage = UIImage(contentsOfFile: path)
                
                UIView.transitionWithView(viewImage!,
                    duration:1,
                    options: UIViewAnimationOptions.TransitionCrossDissolve,
                    animations: { self.viewImage!.image = hiResImage },
                    completion: nil)
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name:kCardDownloadCompleted,  object:nil)
        }
    }
    
    func loadCardImage(sender: AnyObject) {
        if !bCardAnswered {
            return
        }

        let dict = sender.userInfo as Dictionary?
        let card = dict?["card"] as! DTCard
        
        if (cards!.first == card) {
            let path = FileManager.sharedInstance().cardPath(card)
            
            if path != currentCardPath {
                let hiResImage = UIImage(contentsOfFile: path)
                
                UIView.transitionWithView(viewImage!,
                    duration:1,
                    options: UIViewAnimationOptions.TransitionFlipFromLeft,
                    animations: { self.viewImage!.image = hiResImage },
                    completion: nil)
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name:kCardDownloadCompleted,  object:nil)
        }
    }

    func canCastCard() -> Bool {
        var ccBlack     = 0
        var ccBlue      = 0
        var ccGreen     = 0
        var ccRed       = 0
        var ccWhite     = 0
        var ccColorless = 0
        
        for dict in FileManager.sharedInstance().manaImagesForCard(cards!.first) as! [NSDictionary] {
            let symbol = dict["symbol"] as! String
            
            if symbol == "B" {
                ccBlack++
            } else if symbol == "U" {
                ccBlue++
            } else if symbol == "G" {
                ccGreen++
            } else if symbol == "R" {
                ccRed++
            } else if symbol == "W" {
                ccWhite++
            } else if symbol == "1" {
                ccColorless += 1
            } else if symbol == "2" {
                ccColorless += 2
            } else if symbol == "3" {
                ccColorless += 3
            } else if symbol == "4" {
                ccColorless += 4
            } else if symbol == "5" {
                ccColorless += 5
            } else if symbol == "6" {
                ccColorless += 6
            } else if symbol == "7" {
                ccColorless += 7
            } else if symbol == "8" {
                ccColorless += 8
            } else if symbol == "9" {
                ccColorless += 9
            } else if symbol == "10" {
                ccColorless += 10
            } else if symbol == "11" {
                ccColorless += 11
            } else if symbol == "12" {
                ccColorless += 12
            } else if symbol == "13" {
                ccColorless += 13
            } else if symbol == "14" {
                ccColorless += 14
            } else if symbol == "15" {
                ccColorless += 15
            }
        }
        
        var result = false
        
        result = (manaBlack  + manaBlue + manaGreen + manaRed  + manaWhite  + manaColorless) > 0
        result = result &&
            manaBlack >= ccBlack &&
            manaBlue >= ccBlue &&
            manaGreen >= ccGreen &&
            manaRed >= ccRed &&
            manaWhite >= ccWhite &&
            manaColorless >= ccColorless
        return result
    }
    
    func fetchUserManaDone(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        userMana = dict?["userMana"] as? PFObject
        self.updateManaPool()
    }

//  MARK: Event Handlers
    func helpTapped(sender: UITapGestureRecognizer) {
        var sharingItems = Array<AnyObject>()
        
        // get screenshot
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0)
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        sharingItems.append("Help, what is the name of this card? -Decktracker Card Quiz")
        sharingItems.append(screenshot!)
        
        let activityController = UIActivityViewController(activityItems:sharingItems, applicationActivities:nil)
        activityController.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint]
        activityController.completionWithItemsHandler = {(activityType: String!, completed: Bool, returnedItems: [AnyObject]!, activityError: NSError!) -> Void in
            
            if (completed) {
                JJJUtil.alertWithTitle("Help", andMessage:"Help sent.")
            }
        }
        
        self.presentViewController(activityController, animated:true, completion:nil)
    }
    
    func buyTapped(sender: UITapGestureRecognizer) {
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            let filePath = "\(NSBundle.mainBundle().bundlePath)/In-App Mana.plist"
            let arrMana = NSArray(contentsOfFile: filePath)
            var dict:Dictionary<String, String>?
            
            switch selectedIndex {
            case 0:
                dict = arrMana![0] as? Dictionary<String, String>
            case 1:
                dict = arrMana![1] as? Dictionary<String, String>
            case 2:
                dict = arrMana![2] as? Dictionary<String, String>
            default:
                break
            }
            
            let view2 = InAppPurchaseViewController()
            
            view2.delegate = self
            view2.productID = dict!["In-App Product ID"]
            view2.productDetails = ["name": dict!["In-App Display Name"] as String!,
                "description": dict!["In-App Description"] as String!]
            
            self.navigationController?.pushViewController(view2, animated:false)
        }
        
        ActionSheetStringPicker.showPickerWithTitle("Buy Mana",
            rows: ["18 Mana", "60 Mana", "100 Mana"],
            initialSelection: 0,
            doneBlock: doneBlock,
            cancelBlock: nil,
            origin: view)
    }
    
    func nextCardTapped(sender: UITapGestureRecognizer) {
        let hud = MBProgressHUD(view: self.view)
        hud.delegate = self
        self.view.addSubview(hud)
        
        let executingBlock = { () -> Void in
            // clean
            self.lblCastingCost!.removeFromSuperview()
            for view in self.viewCastingCost!.subviews {
                view.removeFromSuperview()
            }
            self.viewCastingCost!.removeFromSuperview()
            self.viewImage!.removeFromSuperview()
            self.btnNextCard!.removeFromSuperview()
        }
        
        let completionBlock = {  () -> Void in
            self.bCardAnswered = false
            self.setupImageView()
            self.setupFunctionButtons()
            self.displayQuiz()
        }
        
        hud.showAnimated(true, whileExecutingBlock:executingBlock, completionBlock:completionBlock)
    }
    
    func castTapped(sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        println("\(label.text!)")
    }
    
    func answerActivated(sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        
        if label.text == "*" {
            return
        }
        
        for arr in arrAnswers! {
            for lblAnswer in arr {
                if lblAnswer.textColor == UIColor.redColor() {
                    lblAnswer.textColor = UIColor.whiteColor()
                }
            }
        }
        
        for lblQuiz in arrQuizzes! {
            if lblQuiz.text == " " {
                lblQuiz.text = label.text
                label.text = "*"
                return
            }
        }
    }
    
    func quizActivated(sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        
        if label.text == " " {
            return
        }
        
        for arr in arrAnswers! {
            var bBreak = false
            
            for lblAnswer in arr {
                if lblAnswer.text == "*" {
                    lblAnswer.text = label.text
                    label.text = " "
                    bBreak = true
                    break
                }
            }
            
            if bBreak {
                break
            }
        }
        
        var answer = String()
        for arr in arrAnswers! {
            for lblAnswer in arr {
                answer += lblAnswer.text!
            }
            answer += " "
        }
        answer = answer.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if answer.rangeOfString("*") == nil {
            if answer.lowercaseString == cards!.first!.name.lowercaseString {
                bCardAnswered = true
                
                // clean up the last card
                switch gameType! {
                case .Easy:
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(kCQEasyCurrentCard)
                case .Moderate:
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(kCQModerateCurrentCard)
                case .Hard:
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(kCQHardCurrentCard)
                }
                
                displayAnswer()
                
            } else {
                for arr in arrAnswers! {
                    for lblAnswer in arr {
                        lblAnswer.textColor = UIColor.redColor()
                    }
                }
            }
        }
    }
    
    func quizForCard(card: DTCard) -> String {
        let xcount = count(card.name)
        var quiz = String()
        var name = Array(card.name)
        
        for i in 0...xcount-1 {
            let random = Int(arc4random_uniform(UInt32(name.count-1)))
            let letter = String(name[random])
            if letter != " " {
                quiz += letter.capitalizedString
            }
            name.removeAtIndex(random)
        }
        
        // add random spaces
        var jumble = String()
        var countQuiz = count(quiz)
        var countSpaces = 20 - countQuiz
        var iQuiz = 0
        var iSpaces = 0
        for i in 0...19 {
            switch Int(arc4random_uniform(UInt32(2))) {
            case 0:
                if iQuiz <= countQuiz-1 {
                    let index = advance(quiz.startIndex, iQuiz)
                    let letter = String(quiz[index])
                    jumble += letter
                    iQuiz++
                    
                } else if iSpaces <= countSpaces-1 {
                    jumble += " "
                    iSpaces++
                    
                }
                
            case 1:
                if iSpaces <= countSpaces-1 {
                    jumble += " "
                    iSpaces++

                } else if iQuiz <= countQuiz-1 {
                    let index = advance(quiz.startIndex, iQuiz)
                    let letter = String(quiz[index])
                    jumble += letter
                    iQuiz++
                    
                }

            default:
                break
            }
        }
        
#if DEBUG
        println("\(card.name)")
#endif
        return jumble
    }
    
//    MARK:  MBProgressHUDDelegate
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
    
//    MARK: InAppPurchaseViewControllerDelegate
    func productPurchaseSucceeded(productID: String) {
        
        if productID == "18Mana_ID" {
            manaBlack     += 3
            manaBlue      += 3
            manaGreen     += 3
            manaRed       += 3
            manaWhite     += 3
            manaColorless += 3
        } else if productID == "60Mana_ID" {
            manaBlack     += 11
            manaBlue      += 11
            manaGreen     += 11
            manaRed       += 11
            manaWhite     += 11
            manaColorless += 5
        } else if productID == "100BMana_ID" {
            manaBlack     += 18
            manaBlue      += 18
            manaGreen     += 18
            manaRed       += 18
            manaWhite     += 18
            manaColorless += 10
        }
        
        // save the mana in the cloud
        self.saveMana()
        
        // update mana pool display
        Database.sharedInstance().fetchUserMana()
    }
}
