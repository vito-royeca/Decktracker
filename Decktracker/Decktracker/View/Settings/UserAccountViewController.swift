//
//  UserAccountViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/8/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class UserAccountViewController: UIViewController {

    var welcomeLabel:UILabel?
    var pictureView:UIImageView?
    var nameLabel:UILabel?
    var logoutButton:UIButton?
    var user:PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let width = self.view.frame.size.width
        var dX:CGFloat = 0
        var dY:CGFloat = 0
        var dWidth:CGFloat = 0
        var dHeight:CGFloat = 0
        
        dWidth = width-100
        dHeight = 30
        dX = (width - dWidth) / 2
        dY = 100
        self.welcomeLabel = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        self.welcomeLabel!.textAlignment = NSTextAlignment.Center;
        
        dY = self.welcomeLabel!.frame.origin.y + self.welcomeLabel!.frame.size.height
        dHeight = 150
        self.pictureView = UIImageView(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        
        dY = self.pictureView!.frame.origin.y + self.pictureView!.frame.size.height
        dHeight = 30
        self.nameLabel = UILabel(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        self.nameLabel!.adjustsFontSizeToFitWidth = true
        self.nameLabel!.textAlignment = NSTextAlignment.Center
        
        dY = self.nameLabel!.frame.origin.y + self.nameLabel!.frame.size.height
        dHeight = 44
        self.logoutButton = UIButton(frame: CGRect(x: dX, y: dY, width: dWidth, height: dHeight))
        self.logoutButton!.titleLabel!.text = "Logout"
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.welcomeLabel!)
        self.view.addSubview(self.pictureView!)
        self.view.addSubview(self.nameLabel!)
        self.view.addSubview(self.logoutButton!)
        
        self.navigationItem.title = "User Account"

        self.loadUser()
        
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "User Account")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUser() {
        self.nameLabel!.text = NSUserDefaults.standardUserDefaults().valueForKey("User_FullName") as String?
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
