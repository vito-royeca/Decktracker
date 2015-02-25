//
//  CardQuizViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 1/14/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class CardQuizViewController: UIViewController {

    var lblBlack:UILabel?
    var lblBlue:UILabel?
    var lblGreen:UILabel?
    var lblRed:UILabel?
    var lblWhite:UILabel?
    var lblColorless:UILabel?
    
    var viewCastingCost:UIView?
    var viewImage:UIImageView?
    var btnAsk:UILabel?
    var btnBuy:UILabel?
    var btnCast:UILabel?
    var arrAnswers:Array<Array<UILabel>>?
    var arrQuizzes:[UILabel]?
//    var answerLines:[String]?
//    var quizLines:[String]?
    var card:DTCard?
    var currentCropPath:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupManaPoints()
        setupImageView()
        setupFunctionButtons()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Card", style: UIBarButtonItemStyle.Plain, target: self, action: "newCardTapped:")
        
        self.navigationItem.title = "Card Quiz"
        self.view.backgroundColor = UIColor.whiteColor()
        
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
        let view = UIView(frame: CGRect(x:10, y:UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height, width:self.view.frame.size.width+5, height:20))
        view.backgroundColor = UIColor.whiteColor()
        
        let manaWidth = (self.view.frame.size.width-10)/6
        let manaImageWidth = CGFloat(16)
        let manaImageHeight = CGFloat(16)
        let manaLabelWidth = manaWidth-manaImageWidth
        
        var dX:CGFloat = 0
        var dY:CGFloat = 5
        var frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        var imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/B/32.png")
        view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaImageHeight)
        lblBlack = UILabel(frame: frame)
        lblBlack!.text = "x0"
        lblBlack!.font = UIFont(name: "Magic:the Gathering", size:18)
        lblBlack!.adjustsFontSizeToFitWidth = true
        view.addSubview(lblBlack!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/U/32.png")
        view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaImageHeight)
        lblBlue = UILabel(frame: frame)
        lblBlue!.text = "x0"
        lblBlue!.font = UIFont(name: "Magic:the Gathering", size:18)
        lblBlue!.adjustsFontSizeToFitWidth = true
        view.addSubview(lblBlue!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/G/32.png")
        view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaImageHeight)
        lblGreen = UILabel(frame: frame)
        lblGreen!.text = "x0"
        lblGreen!.font = UIFont(name: "Magic:the Gathering", size:18)
        lblGreen!.adjustsFontSizeToFitWidth = true
        view.addSubview(lblGreen!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/R/32.png")
        view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaImageHeight)
        lblRed = UILabel(frame: frame)
        lblRed!.text = "x0"
        lblRed!.font = UIFont(name: "Magic:the Gathering", size:18)
        lblRed!.adjustsFontSizeToFitWidth = true
        view.addSubview(lblRed!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/W/32.png")
        view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaImageHeight)
        lblWhite = UILabel(frame: frame)
        lblWhite!.text = "x0"
        lblWhite!.font = UIFont(name: "Magic:the Gathering", size:18)
        lblWhite!.adjustsFontSizeToFitWidth = true
        view.addSubview(lblWhite!)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaImageWidth, height:manaImageHeight)
        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/mana/Colorless/32.png")
        view.addSubview(imageView)
        
        dX = frame.origin.x + frame.size.width
        frame = CGRect(x:dX, y:dY, width:manaLabelWidth, height:manaImageHeight)
        lblColorless = UILabel(frame: frame)
        lblColorless!.text = "x0"
        lblColorless!.font = UIFont(name: "Magic:the Gathering", size:18)
        lblColorless!.adjustsFontSizeToFitWidth = true
        view.addSubview(lblColorless!)
        
        self.view.addSubview(view)
    }
    
    func setupImageView() {
        var dWidth = self.view.frame.size.width * 0.70
        var dX = (self.view.frame.size.width - dWidth) / 2
        var dY = UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height + 40
        var dHeight = CGFloat(16)
        
        var frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        viewCastingCost = UIView(frame: frame)
        self.view.addSubview(viewCastingCost!)
        
        dY = frame.origin.y + frame.size.height
        dHeight = dWidth
        frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        viewImage = UIImageView(frame: frame)
        viewImage!.contentMode = UIViewContentMode.ScaleAspectFit
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
        btnAsk!.text = "ASK FACEBOOK"
        btnAsk!.textAlignment = NSTextAlignment.Center
        btnAsk!.font = UIFont(name: "Magic:the Gathering", size:14)
        btnAsk!.textColor = UIColor.whiteColor()
        btnAsk!.backgroundColor = UIColorFromRGB(0x691F01)
        btnAsk!.layer.borderColor = UIColor.whiteColor().CGColor
        btnAsk!.layer.borderWidth = 1
        btnAsk!.userInteractionEnabled = true
        btnAsk!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "askTapped:"))
        self.view.addSubview(btnAsk!)
        
        // draw the buy button
        dX = dFrame.origin.x + dFrame.size.width
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnBuy = UILabel(frame: dFrame)
        btnBuy!.text = "BUY MANA"
        btnBuy!.textAlignment = NSTextAlignment.Center
        btnBuy!.font = UIFont(name: "Magic:the Gathering", size:14)
        btnBuy!.textColor = UIColor.whiteColor()
        btnBuy!.backgroundColor = UIColorFromRGB(0x691F01)
        btnBuy!.layer.borderColor = UIColor.whiteColor().CGColor
        btnBuy!.layer.borderWidth = 1
        btnBuy!.userInteractionEnabled = true
        btnBuy!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "buyTapped:"))
        self.view.addSubview(btnBuy!)
        
        // draw the cast button
        dX = dFrame.origin.x + dFrame.size.width
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnCast = UILabel(frame: dFrame)
        btnCast!.text = "CAST"
        btnCast!.textAlignment = NSTextAlignment.Center
        btnCast!.font = UIFont(name: "Magic:the Gathering", size:14)
        btnCast!.textColor = UIColor.whiteColor()
        btnCast!.backgroundColor = UIColorFromRGB(0x691F01)
        btnCast!.layer.borderColor = UIColor.whiteColor().CGColor
        btnCast!.layer.borderWidth = 1
        btnCast!.userInteractionEnabled = true
        btnCast!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "castTapped:"))
        self.view.addSubview(btnCast!)
    }

    func newCardTapped(sender: AnyObject) {
        let predicate = NSPredicate(format: "manaCost != nil AND name MATCHES %@", "^.{0,20}") // CMC != nil and name.length <= kMaxQuizCount
        
        let cards = Database.sharedInstance().fetchRandomCards(1, withPredicate: predicate)

        if cards.count >= 1 {
            self.displayCard(cards.first as DTCard)
        }
    }
    
    func displayCard(card: DTCard) {
        self.card = card
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:kCropDownloadCompleted,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"loadCropImage:",  name:kCropDownloadCompleted, object:nil)
        
        // clean
        for view in viewCastingCost!.subviews {
            view.removeFromSuperview()
        }
        if arrAnswers != nil {
            for arr in arrAnswers! {
                for label in arr {
                    label.removeFromSuperview()
                }
            }
        }
        if arrQuizzes != nil {
            for label in arrQuizzes! {
                label.removeFromSuperview()
            }
        }
        
        // draw the mana cost
        let manaImages = FileManager.sharedInstance().manaImagesForCard(card) as [NSDictionary]
        var dX = CGFloat(0)
        var dY = CGFloat(0)
        var index = 0
        var dWidth = viewCastingCost!.frame.size.width - CGFloat(manaImages.count * 16)
        var dHeight = CGFloat(20)
        var dFrame:CGRect?
        let lblCastingCost = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        lblCastingCost.text = "CASTING COST:"
        lblCastingCost.font = UIFont(name: "Magic:the Gathering", size:20)
        lblCastingCost.adjustsFontSizeToFitWidth = true
        viewCastingCost!.addSubview(lblCastingCost)
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
        self.viewImage!.image = UIImage(contentsOfFile: currentCropPath!)
        FileManager.sharedInstance().downloadCropImage(card, immediately:true)
        
        // tokenize the answer
        arrAnswers = Array<Array<UILabel>>()
        var lines = [String]()
        for word in card.name.componentsSeparatedByString(" ") {
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
        dY = self.viewImage!.frame.origin.y + self.viewImage!.frame.size.height + 5
        for line in lines {
            var arr = Array<UILabel>()
            
            dWidth = self.view.frame.size.width/12
            dHeight = 30
            dX = (self.view.frame.width - (dWidth*CGFloat(countElements(line))))/2
            for character in line {
                dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
                let label = UILabel(frame: dFrame!)
                
                if character != " " {
                    label.text = "*"
                    
                    label.textAlignment = NSTextAlignment.Center
                    label.font = UIFont(name: "Magic:the Gathering", size:18)
                    label.textColor = UIColor.whiteColor()
                    label.backgroundColor = UIColorFromRGB(0x691F01)
                    label.layer.borderColor = UIColor.whiteColor().CGColor
                    label.layer.borderWidth = 1
                    label.userInteractionEnabled = true
                    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "answerActivated:"))
//                    label.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "answerActivated:"))
//                    label.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: "quizActivated:"))
                    label.tag = index
                }
                index++
                
                arr.append(label)
                self.view.addSubview(label)
                dX += dWidth
            }
            arrAnswers?.append(arr)
            dY += dHeight
            index++
        }
        
        // draw the quiz
        let quiz = self.quizForCard(card)
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
            label.text = text != nil ? text : ""
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont(name: "Magic:the Gathering", size:20)
            label.textColor = UIColor.whiteColor()
            label.backgroundColor = UIColorFromRGB(0x691F01)
            label.layer.borderColor = UIColor.whiteColor().CGColor
            label.layer.borderWidth = 1
            label.userInteractionEnabled = true
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "quizActivated:"))
//            label.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "quizActivated:"))
//            label.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: "quizActivated:"))
            label.tag = index
            index++
            arrQuizzes!.append(label)
            self.view.addSubview(label)
            
            dX += dFrame!.size.width
        }
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
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
        
        for lblQuiz in arrQuizzes! {
            if lblQuiz.text == "" {
                lblQuiz.text = label.text
                label.text = "*"
                return
            }
        }
    }
    
    func quizActivated(sender: UITapGestureRecognizer) {
        let label = sender.view as UILabel
        
        if label.text == "" {
            return
        }
        
        for arr in arrAnswers! {
            var bBreak = false
            
            for lblAnswer in arr {
                if lblAnswer.text == "*" {
                    lblAnswer.text = label.text
                    label.text = ""
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
        answer.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if answer.lowercaseString == self.card!.name.lowercaseString {
            println("Bingo")
            let predicate = NSPredicate(format: "manaCost != nil AND name MATCHES %@", "^.{0,20}") // CMC != nil and name.length <= kMaxQuizCount
            
            let cards = Database.sharedInstance().fetchRandomCards(1, withPredicate: predicate)
            
            if cards.count >= 1 {
                self.displayCard(cards.first as DTCard)
            }
        }
    }
    
    func quizForCard(card: DTCard) -> String {
//        let alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
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
        
//        for i in 0...19-count-1 {
//            switch i%2 {
//            case 0:
//                if name.count-1 <= 19 {
//                    quiz += ""
//                }
//            case 1:
//                let random = Int(arc4random_uniform(UInt32(name.count-1)))
//                let letter = String(name[random])
//                if letter != " " {
//                    quiz += letter.capitalizedString
//                }
//                name.removeAtIndex(random)
//            default:
//                break
//            }
//        }
        
        return quiz
    }
}
