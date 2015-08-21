//
// Created by Jovit Royeca on 4/8/15.
// Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import Foundation
import AVFoundation

class CardQuizHomeViewController : UIViewController, MBProgressHUDDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

//  MARK: Variables
    var loginViewController:LoginViewController?
    
    var lblTitle:UILabel?
    var lblAccount:UILabel?
    var btnLogin:UILabel?
    var btnEasy:UILabel?
    var btnModerate:UILabel?
    var btnHard:UILabel?
    var btnLeaderboard:UILabel?
//    var btnExit:UILabel?
    var userMana:PFObject?
    
//  MARK: Boilerplate code
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        hidesBottomBarWhenPushed = true
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kParseUserManaDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"fetchUserManaDone:",  name:kParseUserManaDone, object:nil)
        
        var error:NSError?
        var success = AVAudioSession.sharedInstance().setCategory(
            AVAudioSessionCategoryPlayback,
            withOptions: .DefaultToSpeaker, error: &error)
        if !success {
            NSLog("Failed to set audio session category.  Error: \(error)")
        }
        
        setupBackground()
        Database.sharedInstance().fetchUserMana()
        self.setupMenu()
        
#if !DEBUG
        // send the screen to Google Analytics
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: "Card Quiz Home")
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
        var dX = CGFloat(0)
        var dY = UIApplication.sharedApplication().statusBarFrame.size.height + /*self.navigationController!.navigationBar.frame.size.height +*/ 35
        var dWidth = self.view.frame.size.width
        var dHeight = CGFloat(40)
        var dFrame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)

        lblTitle = UILabel(frame: dFrame)
        lblTitle!.text = "Card Quiz"
        lblTitle!.textAlignment = NSTextAlignment.Center
        lblTitle!.font = CQTheme.kTitleLabelFont
        lblTitle!.textColor = CQTheme.kTileTextColor
        self.view.addSubview(lblTitle!)
        
        dY = lblTitle!.frame.origin.y + lblTitle!.frame.size.height + 5
        dHeight = self.view.frame.height - dY - 125
        dFrame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        let circleImage = UIImageView(frame: dFrame)
        circleImage.contentMode = UIViewContentMode.ScaleAspectFill
        circleImage.image = UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Card_Circles.png")
        self.view.addSubview(circleImage)
    }

    func setupMenu() {
        lblAccount?.removeFromSuperview()
        btnLogin?.removeFromSuperview()
        btnEasy?.removeFromSuperview()
        btnModerate?.removeFromSuperview()
        btnHard?.removeFromSuperview()
        btnLeaderboard?.removeFromSuperview()
//        btnExit?.removeFromSuperview()
        
        var dX = self.view.frame.size.width/8
        var dY = lblTitle!.frame.origin.y + lblTitle!.frame.size.height + 5
        var dWidth = self.view.frame.size.width*(3/4)
        var dHeight = CGFloat(40)
        var dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)

        if let currentUser = PFUser.currentUser() {
            lblAccount = UILabel(frame: dFrame)
            lblAccount!.font = CQTheme.kManaLabelFont
            lblAccount!.adjustsFontSizeToFitWidth = true
            lblAccount!.textColor = CQTheme.kManaLabelColor
            lblAccount!.textAlignment = NSTextAlignment.Center
            lblAccount!.text = currentUser["name"] as? String
            self.view.addSubview(lblAccount!)
            
            if PFFacebookUtils.isLinkedWithUser(currentUser) {
                let request = FBRequest.requestForMe()
                
                request.startWithCompletionHandler({ (connection: FBRequestConnection?, result: AnyObject?, error: NSError?) -> Void in
                    if error == nil {
                        let userData = result as! NSDictionary
                        
                        let name = userData["name"] as? String
                        self.lblAccount!.text = name
                        
                        if name != currentUser["name"] as? String {
                            currentUser["name"] = name
                            currentUser.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                
                            })
                        }
                    }
                })
                
            } else if PFTwitterUtils.isLinkedWithUser(currentUser) {
                let requestString = "https://api.twitter.com/1.1/users/show.json?screen_name=\(PFTwitterUtils.twitter()!.screenName!)"
                let verify = NSURL(string: requestString)
                let request = NSMutableURLRequest(URL: verify!)
                PFTwitterUtils.twitter()!.signRequest(request)
                var response:NSURLResponse?
                var error:NSError?
                let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
                
                
                if error == nil {
                    let result = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments, error:&error) as! NSDictionary
                    let name = result["name"] as! String
                    
                    self.lblAccount!.text = name
                    
                    if name != currentUser["name"] as? String {
                        currentUser["name"] = name
                        currentUser.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            
                        })
                    }
                }

            } else {
                lblAccount!.text = currentUser.username!
            }
            
            dY = self.lblAccount!.frame.origin.y + dHeight + 20
            dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
            btnLogin = UILabel(frame: dFrame)
            btnLogin!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "loginTapped:"))
            btnLogin!.userInteractionEnabled = true
            btnLogin!.text = "Logout"
            btnLogin!.textAlignment = NSTextAlignment.Center
            btnLogin!.font = CQTheme.kManaLabelFont
            btnLogin!.textColor = CQTheme.kTileTextColor
            btnLogin!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
            btnLogin!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
            btnLogin!.layer.borderWidth = 1
            self.view.addSubview(btnLogin!)
        } else  {
            btnLogin = UILabel(frame: dFrame)
            btnLogin!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "loginTapped:"))
            btnLogin!.userInteractionEnabled = true
            btnLogin!.text = "Login / Sign Up"
            btnLogin!.textAlignment = NSTextAlignment.Center
            btnLogin!.font = CQTheme.kManaLabelFont
            btnLogin!.textColor = CQTheme.kTileTextColor
            btnLogin!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
            btnLogin!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
            btnLogin!.layer.borderWidth = 1
            self.view.addSubview(btnLogin!)
        }

        dY = self.btnLogin!.frame.origin.y + dHeight + 20
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnEasy = UILabel(frame: dFrame)
        btnEasy!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startGameTapped:"))
        btnEasy!.userInteractionEnabled = true
        btnEasy!.text = "Easy: Standard"
        btnEasy!.textAlignment = NSTextAlignment.Center
        btnEasy!.font = CQTheme.kManaLabelFont
        btnEasy!.textColor = CQTheme.kTileTextColor
        btnEasy!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
        btnEasy!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnEasy!.layer.borderWidth = 1
        self.view.addSubview(btnEasy!)

        dY = self.btnEasy!.frame.origin.y + dHeight + 20
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnModerate = UILabel(frame: dFrame)
        btnModerate!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startGameTapped:"))
        btnModerate!.userInteractionEnabled = true
        btnModerate!.text = "Moderate: Modern"
        btnModerate!.textAlignment = NSTextAlignment.Center
        btnModerate!.font = CQTheme.kManaLabelFont
        btnModerate!.textColor = CQTheme.kTileTextColor
        btnModerate!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
        btnModerate!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnModerate!.layer.borderWidth = 1
        self.view.addSubview(btnModerate!)

        dY = self.btnModerate!.frame.origin.y + dHeight + 20
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnHard = UILabel(frame: dFrame)
        btnHard!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startGameTapped:"))
        btnHard!.userInteractionEnabled = true
        btnHard!.text = "Hard: Vintage"
        btnHard!.textAlignment = NSTextAlignment.Center
        btnHard!.font = CQTheme.kManaLabelFont
        btnHard!.textColor = CQTheme.kTileTextColor
        btnHard!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
        btnHard!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnHard!.layer.borderWidth = 1
        self.view.addSubview(btnHard!)

        dY = self.btnHard!.frame.origin.y + dHeight + 20
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnLeaderboard = UILabel(frame: dFrame)
        btnLeaderboard!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "leaderboardTapped:"))
        btnLeaderboard!.userInteractionEnabled = true
        btnLeaderboard!.text = "Leaderboard"
        btnLeaderboard!.textAlignment = NSTextAlignment.Center
        btnLeaderboard!.font = CQTheme.kManaLabelFont
        btnLeaderboard!.textColor = CQTheme.kTileTextColor
        btnLeaderboard!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
        btnLeaderboard!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnLeaderboard!.layer.borderWidth = 1
        self.view.addSubview(btnLeaderboard!)
        
//        dY = self.btnLeaderboard!.frame.origin.y + dHeight + 20
//        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
//        btnExit = UILabel(frame: dFrame)
//        btnExit!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "exitTapped:"))
//        btnExit!.userInteractionEnabled = true
//        btnExit!.text = "Exit"
//        btnExit!.textAlignment = NSTextAlignment.Center
//        btnExit!.font = CQTheme.kManaLabelFont
//        btnExit!.textColor = CQTheme.kTileTextColor
//        btnExit!.backgroundColor = JJJUtil.colorFromRGB(CQTheme.kTileColor)
//        btnExit!.layer.borderColor = JJJUtil.colorFromRGB(CQTheme.kTileBorderColor).CGColor
//        btnExit!.layer.borderWidth = 1
//        self.view.addSubview(btnExit!)
    }

//   MARK: Logic code
    func fetchUserManaDone(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        userMana = dict?["userMana"] as? PFObject
    }

//   MARK: Event handlers
    func loginTapped(sender: AnyObject) {
        
        if let currentUser = PFUser.currentUser() {
            PFUser.logOut()
            Database.sharedInstance().deleteUserManaLocally()
            Database.sharedInstance().fetchUserMana()
            self.setupMenu()
            
        } else {
            self.loginViewController = LoginViewController()
            self.loginViewController!.delegate = self
            self.loginViewController!.signUpController!.delegate = self
            
            self.presentViewController(self.loginViewController!, animated:true, completion: nil)
        }
    }
    
    func startGameTapped(sender: AnyObject) {
        if let currentUser = PFUser.currentUser() {
            if !PFFacebookUtils.isLinkedWithUser(currentUser) &&
               !PFTwitterUtils.isLinkedWithUser(currentUser) &&
               currentUser["emailVerified"] == nil {
                
                JJJUtil.alertWithTitle("Email Verification", andMessage: "You may need to verify your email address. We have sent you a verification email. Logout first and then login again after verifying your email.")
                return
            }
        }
        
        let hud = MBProgressHUD(view: self.view)
        var game:CardQuizGameViewController?
        
        let executingBlock = { () -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                let tap = sender as! UITapGestureRecognizer
                let button = tap.view as! UILabel
                let title = button.text
                var gameType:String?
                
                if title == "Easy: Standard" {
                    gameType = kCQEasyCurrentCard
                } else if title == "Moderate: Modern" {
                    gameType = kCQModerateCurrentCard
                } else if title == "Hard: Vintage" {
                    gameType = kCQHardCurrentCard
                }
                
                game = CardQuizGameViewController()
                game!.userMana = self.userMana
                game!.gameType = gameType
                
                game!.preloadRandomCards()
            }
        }
        
        let completionBlock = {  () -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(game!, animated: false, completion: nil)
            }
        }
        
        hud.delegate = self
        self.view.addSubview(hud)
        hud.showAnimated(true, whileExecutingBlock:executingBlock, completionBlock:completionBlock)
    }
    
    func leaderboardTapped(sender: AnyObject) {
        var leaderboard = CardQuizLeaderboardViewController()
        self.presentViewController(leaderboard, animated: false, completion: nil)
    }

    func exitTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kParseUserManaDone,  object:nil)
        self.dismissViewControllerAnimated(false, completion: nil)
    }

//    MARK: MBProgressHUDDelegate methods
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
    
//    MARK: PFLoginViewControllerDlegate
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        controller.dismissViewControllerAnimated(true, completion: nil)
        Database.sharedInstance().fetchUserMana()
        self.setupMenu()
    }
    
//    MARK: PFSignUpViewControllerDelegate
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) -> Void {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
        loginViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
