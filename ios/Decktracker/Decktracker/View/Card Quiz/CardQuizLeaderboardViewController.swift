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
        hidesBottomBarWhenPushed = true
        
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
        var html = NSString(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/web/leaderboard.html", encoding: NSUTF8StringEncoding, error: nil)
        var frag = String()
        var i = 1
        
        for leader in leaderboard! {
            let user = leader["user"] as! PFUser
            let totalCMC = leader["totalCMC"] as! NSNumber
//            var name:String?
//            
//            if PFFacebookUtils.isLinkedWithUser(user) {
//                let request = FBRequest.requestForMe()
//                
//                request.startWithCompletionHandler({ (connection: FBRequestConnection?, result: AnyObject?, error: NSError?) -> Void in
//                    if error == nil {
//                        let userData = result as! NSDictionary
//                        
//                        self.lblAccount!.text = userData["name"] as? String
//                    }
//                })
//            }
            frag += "<tr><td>\(i)</td><td>\(user.username)</td><td>\(totalCMC)</td></tr>"
            i++
        }
        html = html!.stringByReplacingOccurrencesOfString("#_PLACEHOLDER_#", withString: frag)
        
        webView!.loadHTMLString(html as! String, baseURL: baseURL)
        hud!.hide(true)
    }
    
//  MARK: MBProgressHUDDelegate
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
}
