//
//  TextsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 20/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

class TextsViewController: UIViewController {

    // MARK: Variables
    var cardOID:NSManagedObjectID?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Card Texts"
        tableView.registerNib(UINib(nibName: "BrowserTableViewCell", bundle: nil), forCellReuseIdentifier: "browserCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UITableViewDataSource
extension TextsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("browserCell", forIndexPath: indexPath)
        
        if let c = cell as? BrowserTableViewCell {
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
            
            var html = "<html>"
            if let text = card.text {
                html += "<h3>Oracle Text</h3>\(text)"
            }
            if let originalText = card.originalText {
                html += "<h3>Original Text</h3>\(originalText)"
            }
            if let flavor = card.flavor {
                html += "<h3>Flavor Text</h3>\(flavor)"
            }
            html += "</html>"
            
            c.toolBar.hidden = true
            c.webView.loadHTMLString(html, baseURL: nil)
        }
        
        return cell
    }
}

// MARK: UITableVIewDelegate
extension TextsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.size.height
    }
}


