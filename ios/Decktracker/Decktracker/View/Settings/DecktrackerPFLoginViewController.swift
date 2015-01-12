//
//  DecktrackerPFLoginViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

public class DecktrackerPFLoginViewController: PFLogInViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColorFromRGB(0x691F01)
        
        var label = UILabel()
        label.font = UIFont(name: "Magic:the Gathering", size:40)
        label.textColor = UIColor.whiteColor()
        label.text = "Decktracker"
//        label.sizeToFit()
        self.logInView.logo = label
        
//        let image = UIImage(named: "\(NSBundle.mainBundle().bundlePath)/images/AppIcon57x57.png")
//        var imageView = UIImageView()
//        let frame = CGRectMake(self.logInView.logo.frame.origin.x, self.logInView.logo.frame.origin.y, 57, 57)
//        println("\(frame)")
//        println("\(self.logInView.logo.frame)")
//        imageView.frame = frame
//        imageView.image = image
//        self.view.addSubview(imageView)

//        self.navigationItem.title = "Login or Signup"

#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Login or Signup")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
