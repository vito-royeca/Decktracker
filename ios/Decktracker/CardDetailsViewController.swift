//
//  CardDetailsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 16/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
class CardDetailsViewController: UIViewController {

    // MARK: Variables
    var cardOID:NSManagedObjectID?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerNib(UINib(nibName: "CardSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "summaryCell")
        tableView.registerNib(UINib(nibName: "CardImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imageCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: UITableViewDataSource
extension CardDetailsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            if let c = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath) as? CardSummaryTableViewCell {
                c.cardOID = cardOID
                cell = c
            }
        case 2:
            if let c = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as? CardImageTableViewCell {
                c.cardOID = cardOID
                cell = c
            }
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("segmentedCell", forIndexPath: indexPath)
        }
        
        
        return cell!
    }
}

// MARK: UITableVIewDelegate
extension CardDetailsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return CardSummaryTableViewCell.CellHeight
        case 2:
            var height = tableView.frame.size.height - CardSummaryTableViewCell.CellHeight - UITableViewAutomaticDimension
            if let navigationController = navigationController {
                height -= navigationController.navigationBar.frame.size.height
            }
            
            return height // - UIApplication.sharedApplication().statusBarFrame.size.height
            
        default:
            return UITableViewAutomaticDimension
        }
    }
}
