//
//  CardQuizViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 1/14/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class CardQuizViewController: UIViewController, MBProgressHUDDelegate {

    let kManaLabelColor  = UIColor.whiteColor()
    let kLabelColor      = UIColor.whiteColor()
    let kTileTextColor   = UIColor.whiteColor()
    let kTileColor       = UInt(0x434343) // silver
    let kTileBorderColor = UInt(0x191919) // black
    
    let kManaLabelFont  = UIFont(name: "Magic:the Gathering", size:18)
    let kLabelFont      = UIFont(name: "Magic:the Gathering", size:20)
    let kTileAnswerFont = UIFont(name: "Magic:the Gathering", size:18)
    let kTileQuizFont   = UIFont(name: "Magic:the Gathering", size:20)
    let kTileButtonFont = UIFont(name: "Magic:the Gathering", size:14)
    
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
//    var circleImage:UIImageView?
    var btnAsk:UILabel?
    var btnBuy:UILabel?
    var btnCast:UILabel?
    var btnNextCard:UILabel?
    var arrAnswers:Array<Array<UILabel>>?
    var arrQuizzes:[UILabel]?
    var card:DTCard?
    var currentCropPath:String?
    var currentCardPath:String?
    var bCardAnswered = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.card = self.generateRandomCard()
        setupManaPoints()
        setupImageView()
        setupFunctionButtons()
        displayCard()
        
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
    
    func hidesBottomBarWhenPushed() -> Bool {
        return true
    }

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
        lblBlack!.font = kManaLabelFont
        lblBlack!.adjustsFontSizeToFitWidth = true
        lblBlack!.textColor = kManaLabelColor
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
        lblBlue!.font = kManaLabelFont
        lblBlue!.adjustsFontSizeToFitWidth = true
        lblBlue!.textColor = kManaLabelColor
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
        lblGreen!.font = kManaLabelFont
        lblGreen!.adjustsFontSizeToFitWidth = true
        lblGreen!.textColor = kManaLabelColor
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
        lblRed!.font = kManaLabelFont
        lblRed!.adjustsFontSizeToFitWidth = true
        lblRed!.textColor = kManaLabelColor
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
        lblWhite!.font = kManaLabelFont
        lblWhite!.adjustsFontSizeToFitWidth = true
        lblWhite!.textColor = kManaLabelColor
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
        lblColorless!.font = kManaLabelFont
        lblColorless!.adjustsFontSizeToFitWidth = true
        lblColorless!.textColor = kManaLabelColor
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
        btnAsk = UILabel(frame: dFrame)
        btnAsk!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "askTapped:"))
        btnAsk!.userInteractionEnabled = true
        btnAsk!.text = "ASK FACEBOOK"
        btnAsk!.textAlignment = NSTextAlignment.Center
        btnAsk!.font = kTileButtonFont
        btnAsk!.textColor = kTileTextColor
        btnAsk!.backgroundColor = UIColorFromRGB(kTileColor)
        btnAsk!.layer.borderColor = UIColorFromRGB(kTileBorderColor).CGColor
        btnAsk!.layer.borderWidth = 1
        self.view.addSubview(btnAsk!)
        
        // draw the buy button
        dX = dFrame.origin.x + dFrame.size.width
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnBuy = UILabel(frame: dFrame)
        btnBuy!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "buyTapped:"))
        btnBuy!.userInteractionEnabled = true
        btnBuy!.text = "BUY MANA"
        btnBuy!.textAlignment = NSTextAlignment.Center
        btnBuy!.font = kTileButtonFont
        btnBuy!.textColor = kTileTextColor
        btnBuy!.backgroundColor = UIColorFromRGB(kTileColor)
        btnBuy!.layer.borderColor = UIColorFromRGB(kTileBorderColor).CGColor
        btnBuy!.layer.borderWidth = 1
        
        self.view.addSubview(btnBuy!)
        
        // draw the cast button
        dX = dFrame.origin.x + dFrame.size.width
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnCast = UILabel(frame: dFrame)
        if canCastCard() {
            btnCast!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "castTapped:"))
            btnCast!.userInteractionEnabled = true
            btnCast!.text = "CAST"
        } else {
            btnCast!.userInteractionEnabled = false
            btnCast!.text = " "
        }
        btnCast!.textAlignment = NSTextAlignment.Center
        btnCast!.font = kTileButtonFont
        btnCast!.textColor = kTileTextColor
        btnCast!.backgroundColor = UIColorFromRGB(kTileColor)
        btnCast!.layer.borderColor = UIColorFromRGB(kTileBorderColor).CGColor
        btnCast!.layer.borderWidth = 1
        
        self.view.addSubview(btnCast!)
    }

    func generateRandomCard() -> DTCard {
        // CMC != 0 and name.length <= kMaxQuizCount
        let predicate = NSPredicate(format: "cmc >= 1 AND cmc <= 15 AND name MATCHES %@", "^.{0,20}")
        let cards = Database.sharedInstance().fetchRandomCards(1, withPredicate: predicate)
        
        return cards.first as DTCard
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
            
            self.card = self.generateRandomCard()
        }
        
        let completionBlock = {  () -> Void in
            self.bCardAnswered = false
            self.setupImageView()
            self.setupFunctionButtons()
            self.displayCard()
        }
        
        hud.showAnimated(true, whileExecutingBlock:executingBlock, completionBlock:completionBlock)
    }
    
    func displayCard() {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCardDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCardImage:",  name:kCardDownloadCompleted, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCropDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCropImage:",  name:kCropDownloadCompleted, object:nil)
        
        // draw the mana cost
        let manaImages = FileManager.sharedInstance().manaImagesForCard(card) as [NSDictionary]
        var dX = CGFloat(0)
        var dY = CGFloat(0)
        var index = 0
        var dWidth = viewCastingCost!.frame.size.width - CGFloat(manaImages.count * 16)
        var dHeight = CGFloat(20)
        var dFrame:CGRect?
        lblCastingCost = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        lblCastingCost!.text = "Casting Cost: "
        lblCastingCost!.font = kLabelFont
        lblCastingCost!.adjustsFontSizeToFitWidth = true
        lblCastingCost!.textColor = kLabelColor
        viewCastingCost!.addSubview(lblCastingCost!)
        for dict in manaImages {
            dWidth = CGFloat((dict["width"] as NSNumber).floatValue)
            dHeight = CGFloat((dict["height"] as NSNumber).floatValue)
            let path = dict["path"] as String
            dX = viewCastingCost!.frame.size.width - (CGFloat(manaImages.count-index) * dWidth)
            
            dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
            let imgMana = UIImageView(frame: dFrame!)
            
            imgMana.image = UIImage(contentsOfFile: path)
            viewCastingCost!.addSubview(imgMana)
            index++
        }
        
        // load the image
        currentCropPath = FileManager.sharedInstance().cropPath(card)
        viewImage!.image = UIImage(contentsOfFile: currentCropPath!)
        FileManager.sharedInstance().downloadCardImage(card, immediately:true)
        FileManager.sharedInstance().downloadCropImage(card, immediately:true)
        
        // tokenize the answer
        arrAnswers = Array<Array<UILabel>>()
        var lines = [String]()
        for word in self.card!.name.componentsSeparatedByString(" ") {
            var line = lines.last != nil ? lines.last : word
            
            if word == line {
                lines.append(word)
                
            } else {
                if countElements(line!) + countElements(word) + 1 <= 12 {
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
            dX = (self.view.frame.width - (dWidth*CGFloat(countElements(line))))/2
            for character in line {
                dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
                let label = UILabel(frame: dFrame!)
                
                if character != " " {
                    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "answerActivated:"))
                    label.userInteractionEnabled = true
                    label.text = "*"
                    label.textAlignment = NSTextAlignment.Center
                    label.font = kTileAnswerFont
                    label.textColor = kTileTextColor
                    label.backgroundColor = UIColorFromRGB(kTileColor)
                    label.layer.borderColor = UIColorFromRGB(kTileBorderColor).CGColor
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
        let quiz = self.quizForCard(self.card!)
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
            if i <= countElements(quiz)-1 {
                let quizIndex = advance(quiz.startIndex, i)
                text = String(quiz[quizIndex])
            }
            
            let label = UILabel(frame: dFrame!)
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "quizActivated:"))
            label.userInteractionEnabled = true
            label.text = text != nil ? text : " "
            label.textAlignment = NSTextAlignment.Center
            label.font = kTileQuizFont
            label.textColor = kTileTextColor
            label.backgroundColor = UIColorFromRGB(kTileColor)
            label.layer.borderColor = UIColorFromRGB(kTileBorderColor).CGColor
            label.layer.borderWidth = 1
            label.tag = index
            index++
            arrQuizzes!.append(label)
            self.view.addSubview(label)
            
            dX += dFrame!.size.width
        }
    }
    
    func displayReward() {
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
        btnAsk!.removeFromSuperview()
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
        currentCardPath = FileManager.sharedInstance().cardPath(card)
        viewImage!.image = UIImage(contentsOfFile: currentCardPath!)
        FileManager.sharedInstance().downloadCardImage(card, immediately:true)
        
        // draw the next card button
        btnNextCard = UILabel(frame: btnNextCardFrame)
        btnNextCard!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "nextCardTapped:"))
        btnNextCard!.userInteractionEnabled = true
        btnNextCard!.text = "NEXT CARD"
        btnNextCard!.textAlignment = NSTextAlignment.Center
        btnNextCard!.font = kTileButtonFont
        btnNextCard!.textColor = kTileTextColor
        btnNextCard!.backgroundColor = UIColorFromRGB(kTileColor)
        btnNextCard!.layer.borderColor = UIColorFromRGB(kTileBorderColor).CGColor
        btnNextCard!.layer.borderWidth = 1
        self.view.addSubview(btnNextCard!)
        
        // update the mana pool
        for dict in FileManager.sharedInstance().manaImagesForCard(card) as [NSDictionary] {
            let symbol = dict["symbol"] as String
            
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
    }
    
    func loadCropImage(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        let card = dict?["card"] as DTCard
        
        if (self.card == card) {
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
                name:kCropDownloadCompleted,  object:nil)
        }
    }
    
    func loadCardImage(sender: AnyObject) {
        if !bCardAnswered {
            return
        }

        let dict = sender.userInfo as Dictionary?
        let card = dict?["card"] as DTCard
        
        if (self.card == card) {
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
                name:kCropDownloadCompleted,  object:nil)
        }
    }
    
    func askTapped(sender: UITapGestureRecognizer) {
        let label = sender.view as UILabel
        println("\(label.text!)")
    }
    
    func buyTapped(sender: UITapGestureRecognizer) {
        let label = sender.view as UILabel
        println("\(label.text!)")
    }
    
    func castTapped(sender: UITapGestureRecognizer) {
        let label = sender.view as UILabel
        println("\(label.text!)")
    }
    
    func answerActivated(sender: UITapGestureRecognizer) {
        let label = sender.view as UILabel
        
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
        let label = sender.view as UILabel
        
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
            if answer.lowercaseString == self.card!.name.lowercaseString {
                bCardAnswered = true
                displayReward()
                
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
        let count = countElements(card.name)
        var quiz = String()
        var name = Array(card.name)
        
        for i in 0...count-1 {
            let random = Int(arc4random_uniform(UInt32(name.count-1)))
            let letter = String(name[random])
            if letter != " " {
                quiz += letter.capitalizedString
            }
            name.removeAtIndex(random)
        }
        
        // add random spaces
        var jumble = String()
        var countQuiz = countElements(quiz)
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
        println("\(card.name)")
        return jumble
    }
    
    func canCastCard() -> Bool {
        var ccBlack     = 0
        var ccBlue      = 0
        var ccGreen     = 0
        var ccRed       = 0
        var ccWhite     = 0
        var ccColorless = 0
        
        for dict in FileManager.sharedInstance().manaImagesForCard(card) as [NSDictionary] {
            let symbol = dict["symbol"] as String
            
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
        
        return
            (manaBlack  + manaBlue + manaGreen + manaRed  + manaWhite  + manaColorless) > 0 &&
            manaBlack >= ccBlack &&
            manaBlue >= ccBlue &&
            manaGreen >= ccGreen &&
            manaRed >= ccRed &&
            manaWhite >= ccWhite &&
            manaColorless >= ccColorless
    }
    
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

//    Mark - MBProgressHUDDelegate methods
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
}
