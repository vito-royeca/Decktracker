//
// Created by Jovit Royeca on 4/8/15.
// Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import Foundation

class CardQuizHomeViewController : UIViewController, MBProgressHUDDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var loginViewController:LoginViewController?
    var lblAccount:UILabel?
    var btnLogin:UILabel?
    var btnEasy:UILabel?
    var btnModerate:UILabel?
    var btnHard:UILabel?
    var btnLeaderboard:UILabel?
    var userMana:PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hidesBottomBarWhenPushed = true
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kParseUserManaDone,  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"fetchUserManaDone:",  name:kParseUserManaDone, object:nil)
        
        setupBackground()
        self.navigationItem.title = "Card Quiz"
        Database.sharedInstance().fetchUserMana()
        
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Card Quiz Home")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }
    
    override func viewDidAppear(animated: Bool) {
        self.setupMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func fetchUserManaDone(sender: AnyObject) {
        let dict = sender.userInfo as Dictionary?
        userMana = dict?["userMana"] as? PFObject
    }
    
    func setupBackground() {
        var dWidth = self.view.frame.size.width
        var dX = CGFloat(0)
        var dY = UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height
        var dHeight = self.view.frame.height - dY - 120
        var frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)

        let circleImage = UIImageView(frame: frame)
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
        
        var dX = self.view.frame.size.width/8
        var dY = UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height + 40
        var dWidth = self.view.frame.size.width*(3/4)
        var dHeight = CGFloat(40)
        var dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)

        if let currentUser = PFUser.currentUser() {
            lblAccount = UILabel(frame: dFrame)
            lblAccount!.font = CQTheme.kManaLabelFont
            lblAccount!.adjustsFontSizeToFitWidth = true
            lblAccount!.textColor = CQTheme.kManaLabelColor
            lblAccount!.textAlignment = NSTextAlignment.Center
            self.view.addSubview(lblAccount!)
            
            if PFFacebookUtils.isLinkedWithUser(currentUser) {
                let request = FBRequest.requestForMe()
                
                request.startWithCompletionHandler({ (connection: FBRequestConnection?, result: AnyObject?, error: NSError?) -> Void in
                    if error == nil {
                        let userData = result as! NSDictionary
                        
                        self.lblAccount!.text = userData["name"] as? String
                    }
                })
                
            } else if PFTwitterUtils.isLinkedWithUser(currentUser) {
                
            } else {
                lblAccount!.text = currentUser.username
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
            btnLogin!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
            btnLogin!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
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
            btnLogin!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
            btnLogin!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
            btnLogin!.layer.borderWidth = 1
            self.view.addSubview(btnLogin!)
        }

        dY = self.btnLogin!.frame.origin.y + dHeight + 20
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnEasy = UILabel(frame: dFrame)
        btnEasy!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startGame:"))
        btnEasy!.userInteractionEnabled = true
        btnEasy!.text = "Easy: Standard"
        btnEasy!.textAlignment = NSTextAlignment.Center
        btnEasy!.font = CQTheme.kManaLabelFont
        btnEasy!.textColor = CQTheme.kTileTextColor
        btnEasy!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
        btnEasy!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnEasy!.layer.borderWidth = 1
        self.view.addSubview(btnEasy!)

        dY = self.btnEasy!.frame.origin.y + dHeight + 20
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnModerate = UILabel(frame: dFrame)
        btnModerate!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startGame:"))
        btnModerate!.userInteractionEnabled = true
        btnModerate!.text = "Moderate: Modern"
        btnModerate!.textAlignment = NSTextAlignment.Center
        btnModerate!.font = CQTheme.kManaLabelFont
        btnModerate!.textColor = CQTheme.kTileTextColor
        btnModerate!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
        btnModerate!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnModerate!.layer.borderWidth = 1
        self.view.addSubview(btnModerate!)

        dY = self.btnModerate!.frame.origin.y + dHeight + 20
        dFrame = CGRect(x: dX, y: dY, width: dWidth, height: dHeight)
        btnHard = UILabel(frame: dFrame)
        btnHard!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startGame:"))
        btnHard!.userInteractionEnabled = true
        btnHard!.text = "Hard: Vintage"
        btnHard!.textAlignment = NSTextAlignment.Center
        btnHard!.font = CQTheme.kManaLabelFont
        btnHard!.textColor = CQTheme.kTileTextColor
        btnHard!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
        btnHard!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
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
        btnLeaderboard!.backgroundColor = JJJUtil.UIColorFromRGB(CQTheme.kTileColor)
        btnLeaderboard!.layer.borderColor = JJJUtil.UIColorFromRGB(CQTheme.kTileBorderColor).CGColor
        btnLeaderboard!.layer.borderWidth = 1
        self.view.addSubview(btnLeaderboard!)
    }

    func loginTapped(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        
        if currentUser == nil {
            self.loginViewController = LoginViewController()
            self.loginViewController!.delegate = self
            self.loginViewController!.signUpController!.delegate = self
            
            self.navigationController?.presentViewController(self.loginViewController!, animated:true, completion: nil)

        } else {
            PFUser.logOut()
            Database.sharedInstance().deleteUserManaLocally()
            Database.sharedInstance().fetchUserMana()
            self.setupMenu()
        }
    }
    
    func startGame(sender: AnyObject) {
        let hud = MBProgressHUD(view: self.view)
        var game:CardQuizGameViewController?
        
        let executingBlock = { () -> Void in
            let tap = sender as! UITapGestureRecognizer
            let button = tap.view as! UILabel
            let title = button.text
            var gameType:CQGameType?
            
            if title == "Easy: Standard" {
                gameType = .Easy
                
            } else if title == "Moderate: Modern" {
                gameType = .Moderate
                
            } else if title == "Hard: Vintage" {
                gameType = .Hard
            }
            
            game = CardQuizGameViewController()
            game!.gameType = gameType
            game!.userMana = self.userMana
        }
        
        let completionBlock = {  () -> Void in
            self.navigationController!.pushViewController(game!, animated:true)
        }
        
        hud.delegate = self
        self.view.addSubview(hud)
        hud.showAnimated(true, whileExecutingBlock:executingBlock, completionBlock:completionBlock)
    }
    
    func leaderboardTapped(sender: AnyObject) {
        var leaderboard = CardQuizLeaderboardViewController()
        self.navigationController!.pushViewController(leaderboard, animated:true)
    }
    
//    MARK: MBProgressHUDDelegate methods
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
    
//    MARK: PFLoginViewControllerDlegate
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        controller.dismissViewControllerAnimated(true, completion: nil)
        Database.sharedInstance().fetchUserMana()
    }
    
//    MARK: PFSignUpViewControllerDelegate
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) -> Void {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
        loginViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
