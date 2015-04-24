//
//  LifeCounterViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 1/18/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class LifeCounterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Life Counter"
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: self.navigationItem.title)
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
