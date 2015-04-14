//
//  CardQuizLeaderboardViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 4/14/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class CardQuizLeaderboardViewController: UIViewController, MBProgressHUDDelegate {

    var hud:MBProgressHUD?
    var webView:UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kParseLeaderboardDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"fetchLeaderboardDone:",  name:kParseLeaderboardDone, object:nil)
        
        var dX = CGFloat(0)
        var dY = CGFloat(0) //UIApplication.sharedApplication().statusBarFrame.size.height
        var dWidth = self.view.frame.size.width
        var dHeight = self.view.frame.height
        var frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        webView = UIWebView(frame: frame)
        self.view.addSubview(webView!)
        self.navigationItem.title = "Leaderboard"
        fetchLeaderboard(nil)
        
        
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
        let base = "\(NSBundle.mainBundle().bundlePath)/web"
        var html = NSString(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/web/leaderboard.html", encoding: 0, error: nil)
        var frag = String()
        var i = 1
        
        for leader in leaderboard! {
            let name = leader["user"]["username"] as! String
            let totalCMC = leader["totalCMC"] as NSNumber
            
            frag += "<tr><td>\(i)</td><td>\(name)</td><td>\(totalCMC)</td></tr>"
            i++
        }
        html = html!.stringByReplacingOccurrencesOfString("#_PLACEHOLDER_#", withString: frag)
        
        webView!.loadHTMLString(html, baseURL: NSURL(string: base))
        hud!.hide(true)
    }
    
//  MARK: MBProgressHUDDelegate
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
}
