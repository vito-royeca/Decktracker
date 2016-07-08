//
//  CardQuizLeaderboardViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 4/14/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit
import AVFoundation

class CardQuizLeaderboardViewController: UIViewController, MBProgressHUDDelegate {

    var hud:MBProgressHUD?
    var btnClose:UIImageView?
    var webView:UIWebView?
    
    var backgroundSoundPlayer:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hidesBottomBarWhenPushed = true
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kParseLeaderboardDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"fetchLeaderboardDone:",  name:kParseLeaderboardDone, object:nil)

        // load the sounds
        backgroundSoundPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("/audio/cardquiz_leaderboard", ofType: "caf")!), fileTypeHint: AVFileTypeCoreAudioFormat)
        backgroundSoundPlayer!.prepareToPlay()
        backgroundSoundPlayer!.volume = 1.0
        
        setupBackground()
        fetchLeaderboard(nil)
#if !DEBUG
        // send the screen to Google Analytics
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: "Leaderboard")
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.None
    }

    //  MARK: UI code
    func setupBackground() {
        // play the background sound infinitely
        backgroundSoundPlayer!.numberOfLoops = -1
        backgroundSoundPlayer!.play()
        
        var dX = CGFloat(5)
        var dY = CGFloat(5)
        var dWidth = CGFloat(30)
        var dHeight = CGFloat(30)
        var dFrame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        btnClose = UIImageView(frame: dFrame)
        btnClose!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "closeTapped:"))
        btnClose!.userInteractionEnabled = true
        btnClose!.contentMode = UIViewContentMode.ScaleAspectFill
        btnClose!.image = UIImage(named: "cancel.png")
        self.view.addSubview(btnClose!)
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)
        
        dX = CGFloat(0)
        dY = btnClose!.frame.origin.y + btnClose!.frame.size.height + 10
        dWidth = self.view.frame.size.width
        dHeight = self.view.frame.height - dY - 125
        dFrame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        let circleImage = UIImageView(frame: dFrame)
        circleImage.contentMode = UIViewContentMode.ScaleAspectFill
        circleImage.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Card_Circles.png")
        self.view.addSubview(circleImage)
        

        dHeight = self.view.frame.height - dY
        dFrame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        webView = UIWebView(frame: dFrame)
        webView!.backgroundColor = UIColor.clearColor()
        webView!.opaque = false
        self.view.addSubview(webView!)
    }

//  MARK: Logic code
    func fetchLeaderboard(sender: AnyObject?) {
        hud = MBProgressHUD(view: view)
        hud!.delegate = self
        view.addSubview(hud!)
        
        hud!.show(true)
        Database.sharedInstance().fetchLeaderboard()
    }
    
    func fetchLeaderboardDone(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        let leaderboard = dict?["leaderboard"] as? Array<PFObject>
        let baseURL = NSURL(fileURLWithPath: "\(NSBundle.mainBundle().bundlePath)/web")
        var html = try? NSString(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/web/leaderboard.html", encoding: NSUTF8StringEncoding)
        var frag = String()
        var i = 1
        
        for leader in leaderboard! {
            let user      = leader.objectForKey("user") as! PFUser
            let black     = leader.objectForKey("black") as! NSNumber
            let blue      = leader.objectForKey("blue") as! NSNumber
            let green     = leader.objectForKey("green") as! NSNumber
            let red       = leader.objectForKey("red") as! NSNumber
            let white     = leader.objectForKey("white") as! NSNumber
            let colorless = leader.objectForKey("colorless") as! NSNumber
            let totalCMC  = leader.objectForKey("totalCMC") as! NSNumber
            var name:String?
            
            if let x = user.objectForKey("name") as? String {
                name = x
            } else {
                name = user.objectForKey("username") as? String
            }
            
            frag += "<tr><td class='td_rank'>\(i)</td><td class='td_player' colspan='12'>\(name!)</td></tr>"
            frag += "<tr><td>&nbsp;</td><td class='td_player' colspan='12'>Score: \(totalCMC)</td></tr>"
            frag += "<tr><td>&nbsp;</td>"
            
            frag += "<td><img src='../images/mana/B/32.png' width='16' height='16'></td>"
            frag += "<td class='td_score'>\(black)</td>"
            
            frag += "<td><img src='../images/mana/U/32.png' width='16' height='16'></td>"
            frag += "<td class='td_score'>\(blue)</td>"
            
            frag += "<td><img src='../images/mana/G/32.png' width='16' height='16'></td>"
            frag += "<td class='td_score'>\(green)</td>"
            
            frag += "<td><img src='../images/mana/R/32.png' width='16' height='16'></td>"
            frag += "<td class='td_score'>\(red)</td>"
            
            frag += "<td><img src='../images/mana/W/32.png' width='16' height='16'></td>"
            frag += "<td class='td_score'>\(white)</td>"
            
            frag += "<td><img src='../images/mana/Colorless/32.png' width='16' height='16'></td>"
            frag += "<td class='td_score'>\(colorless)</td>"
            
            frag += "</tr><tr><td colspan='13'>&nbsp;</td></tr>"
            i++
        }
        html = html!.stringByReplacingOccurrencesOfString("#_PLACEHOLDER_#", withString: frag)
        
        webView!.loadHTMLString(html as! String, baseURL: baseURL)
        hud!.hide(true)
    }
    
//  MARK: Event handlers
    func closeTapped(sender: AnyObject) {
        self.backgroundSoundPlayer!.stop()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
//  MARK: MBProgressHUDDelegate
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
}
