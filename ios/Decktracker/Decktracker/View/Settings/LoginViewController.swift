//
//  DecktrackerPFLoginViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

public class LoginViewController: PFLogInViewController {
    
    init() {
        super.init(nibName:nil,bundle:nil)
        
        self.fields = (PFLogInFields.DismissButton |
                    PFLogInFields.UsernameAndPassword |
                    PFLogInFields.LogInButton |
                    PFLogInFields.SignUpButton |
                    PFLogInFields.PasswordForgotten |
                    PFLogInFields.Facebook |
                    PFLogInFields.Twitter)
        
        self.signUpController = SignupViewController()
    }
    
    // the following is also required if implementing an initializer
    required public init(coder:NSCoder) {
        super.init(coder:coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hidesBottomBarWhenPushed = true
        
        self.view.backgroundColor = JJJUtil.UIColorFromRGB(0x691F01)
        
        let image = UIImage(named: "\(NSBundle.mainBundle().bundlePath)/images/AppIcon57x57.png")
        var imageView = UIImageView(frame: CGRectMake(0, 0, 57, 57))
        imageView.image = image
        self.logInView!.logo = imageView

        self.navigationItem.title = "Login or Signup"

#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Login or Signup")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
#endif
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
