//
//  SignupViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 4/8/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class SignupViewController: PFSignUpViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = FileManager.sharedInstance().UIColorFromRGB(0x691F01)
        
        let image = UIImage(named: "\(NSBundle.mainBundle().bundlePath)/images/AppIcon57x57.png")
        var imageView = UIImageView(frame: CGRectMake(0, 0, 57, 57))
        imageView.image = image
        self.signUpView.logo = imageView
        
        self.navigationItem.title = "Signup"
        
        #if !DEBUG
            // send the screen to Google Analytics
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: "Signup")
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
