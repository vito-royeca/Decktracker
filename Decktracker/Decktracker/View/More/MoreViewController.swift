//
//  MoreViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 10/17/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

public class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ReaderViewControllerDelegate {
    
    var tblMore:UITableView!
    let arrayData = ["Rules": ["Basic Rulebook", "Comprehensive Rules"],
                     "Restricted List": ["Vintage", "Legacy", "Modern"],
                     "Banned List": ["Vintage", "Legacy", "Modern"],
                     "Other Lists": ["Reserved"]]
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let height = view.frame.size.height - tabBarController!.tabBar.frame.size.height
        let frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        tblMore = UITableView(frame: frame, style: UITableViewStyle.Grouped)
        tblMore.delegate = self
        tblMore.dataSource = self
        
        view.addSubview(tblMore)
        self.navigationItem.title = "More"
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let key = Array(arrayData.keys)[section]
        let dict = arrayData[key]!
        return dict.count
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return Array(arrayData.keys).count
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return Array(arrayData.keys)[section]
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        let key = Array(arrayData.keys)[indexPath.section]
        let dict = arrayData[key]!
        let value = dict[indexPath.row]
        
        cell.textLabel?.text = value
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    // UITableViewDelegate
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var view:UIViewController!;
        
        let key = Array(arrayData.keys)[indexPath.section]
        let dict = arrayData[key]!
        let value = dict[indexPath.row]
        
        switch (indexPath.section) {
        case 0:
            let pdfs = NSBundle.mainBundle().pathsForResourcesOfType("pdf", inDirectory:"rules")
            let file = pdfs[indexPath.row] as NSString
            let document = ReaderDocument.withDocumentFilePath(file, password: nil)
            let readerView = ReaderViewController(readerDocument:document)
            readerView.delegate = self
            view = readerView
            view.hidesBottomBarWhenPushed = true
            navigationController?.setNavigationBarHidden(true, animated:true)
            
        case 1:
            let searchView = SimpleSearchViewController()
            let restricted = CardLegality.MR_findAllWithPredicate(NSPredicate(format:"name == %@ AND format.name == %@", "Restricted", value))
            let predicate = NSPredicate(format: "ANY legalities IN %@", restricted)
            searchView.predicate = predicate
            searchView.titleString = "\(key) - \(value)"
            searchView.doSearch()
            view = searchView

        case 2:
            let searchView = SimpleSearchViewController()
            let banned = CardLegality.MR_findAllWithPredicate(NSPredicate(format:"name == %@ AND format.name == %@", "Banned", value))
            let predicate = NSPredicate(format: "ANY legalities IN %@", banned)
            searchView.predicate = predicate
            searchView.titleString = "\(key) - \(value)"
            searchView.doSearch()
            view = searchView

        case 3:
            let searchView = SimpleSearchViewController()
            let predicate = NSPredicate(format: "reserved == %@", true)
            searchView.predicate = predicate
            searchView.titleString = "\(key) - \(value)"
            searchView.doSearch()
            view = searchView

        default:
            view = nil;
        }
        
        if view != nil {
            navigationController?.pushViewController(view, animated:true)
        }
    }
    
    // ReaderViewControllerDelegate
    public func dismissReaderViewController(viewController:ReaderViewController)
    {
        navigationController?.popViewControllerAnimated(true);
        navigationController?.setNavigationBarHidden(false, animated:true)
    }
}
