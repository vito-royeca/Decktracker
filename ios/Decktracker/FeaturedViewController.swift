//
//  FeaturedViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

class FeaturedViewController: UIViewController {

    // MARK: Variables
    var setsFetchRequest:NSFetchRequest?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "sets")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadSets()
    }
    
    // MARK: Custom methods
    func loadSets() {
        setsFetchRequest = NSFetchRequest(entityName: "Set")
        setsFetchRequest!.fetchLimit = 10
        setsFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "releaseDate", ascending: false),
            NSSortDescriptor(key: "name", ascending: true)]
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension FeaturedViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("sets", forIndexPath: indexPath) as! ThumbnailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Sets"
            cell.fetchRequest = setsFetchRequest
        default:
            ()
        }
     
        cell.tag = indexPath.row
        cell.delegate = self
        cell.loadData()
        return cell
    }
}

// MARK: UITableViewDelegate
extension FeaturedViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ThumbnailTableViewCell.CellHeight
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension FeaturedViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        switch tag {
        case 0: // Sets
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SetsViewController") as? SetsViewController,
                let navigationController = navigationController {
                navigationController.pushViewController(controller, animated: true)
            }
        default:
            ()
        }
    }
    
    func didSelectItem(tag: Int, objectID: NSManagedObjectID, path: NSIndexPath) {
        switch tag {
        case 0: // Sets
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SetDetailsViewController") as? SetDetailsViewController,
                let navigationController = navigationController {
                let set = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(objectID) as! Set
                
                controller.setOID = objectID
                controller.navigationItem.title = set.name!
                navigationController.pushViewController(controller, animated: true)
            }
            
        default:
            ()
        }
    }
}