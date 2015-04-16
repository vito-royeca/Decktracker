//
//  ComprehensiveRulesViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

class ComprehensiveRulesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate {
    
    let kCellIdentifier = "CellIdentifier"
    
    var tblRules:UITableView?
    var webView:UIWebView?
    var path:String?
    var data:[String: [String]]?
    var showSections = false
    var sections:[String: [String]]?
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init() {
        super.init(nibName:nil,bundle:nil)
        
        self.loadTableOfContents()
    }
    
    init(data: [String: [String]], showSections: Bool) {
        super.init(nibName:nil,bundle:nil)
        
        self.data = data
        self.showSections = showSections
        
        if self.showSections {
            sections = [String: [String]]()
            let key = Array(data.keys)[0]
            let dict = data[key]
            
            for term in dict! {
                let letter = term.substringWithRange(Range(start: term.startIndex, end: advance(term.startIndex, 1)))
                
                if !contains(sections!.keys, letter) {
                    sections!.updateValue([String](), forKey: letter)
                }
                
                var array = sections![letter]
                array!.append(term)
                sections!.updateValue(array!, forKey: letter)
            }
        }
    }
    
    init(path: String) {
        super.init(nibName:nil,bundle:nil)
        
        self.path = path
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let height = view.frame.size.height //- tabBarController!.tabBar.frame.size.height
        var frame = CGRect(x:0, y:0, width:view.frame.width, height:height)
        
        if let oData = data {
            tblRules = UITableView(frame: frame, style: UITableViewStyle.Plain)
            
            tblRules!.delegate = self
            tblRules!.dataSource = self
            tblRules!.registerClass(SubtitleTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
            tblRules!.rowHeight = UITableViewAutomaticDimension
            tblRules!.estimatedRowHeight = 44.0
            view.addSubview(tblRules!)
        
        } else if let oPath = path {
            webView = UIWebView(frame: frame)
            
            webView!.delegate = self
            view.addSubview(webView!)
            webView!.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: oPath)!))
        }
        
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Comprehensive Rules")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func loadTableOfContents() {
        self.navigationItem.title = "Comprehensive Rules"
        
        var array = [String]()
        array.append("Introduction")
        for rule in DTComprehensiveRule.MR_findByAttribute("parent", withValue:nil) {
            array.append(rule.number + ". " + rule.rule)
        }
        array.append("Glossary")
        array.append("Credits")
        data = ["Table Of Contents": array]
    }

//    MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSections {
            let keys = Array(sections!.keys).sorted(<)
            let key = keys[section]
            let values = sections![key]
            return values!.count

        } else {
        
            let key = Array(data!.keys)[section]
            let dict = data![key]
            return dict!.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        if showSections {
            return Array(sections!.keys).count
        }
        return 1
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        if showSections {
            return Array(sections!.keys).sorted(<)
        }
        return nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if showSections {
            let keys = Array(sections!.keys).sorted(<)
            return keys[section]
        }
        return nil
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var section = -1
        
        if showSections {
            let keys = Array(sections!.keys).sorted(<)
            
            for (i, value) in enumerate(keys) {
                if title == value {
                    section = i
                }
            }
        }
        
        return section
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var key:String?
        var value:String?
        
        if showSections {
            let keys = Array(sections!.keys).sorted(<)
            key = keys[indexPath.section]
            let values = sections![key!]
            value = values![indexPath.row]
            
        } else {
            key = Array(data!.keys)[indexPath.section]
            let dict = data![key!]
            value = dict![indexPath.row]
        }
        
        if let cell: SubtitleTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as? SubtitleTableViewCell {
            
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.titleLabel.text = value
            
            key = Array(data!.keys)[0]
            
            if key == "Rules" {
                var number:NSString = value!
                var range:NSRange = number.rangeOfString(" ")
                number = number.substringToIndex(range.location-1)
                if let rule = DTComprehensiveRule.MR_findFirstByAttribute("number", withValue:number) as? DTComprehensiveRule {
                    if rule.children.count == 0 {
                        cell.accessoryType = UITableViewCellAccessoryType.None
                        cell.titleLabel.text = rule.number
                        cell.bodyLabel.text = rule.rule
                    }
                }

            } else if key == "Glossary" {
                if let glossary = DTComprehensiveGlossary.MR_findFirstByAttribute("term", withValue:value) as? DTComprehensiveGlossary {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                    cell.titleLabel.text = glossary.term
                    cell.bodyLabel.text = glossary.definition
                }
            }
            
            
            cell.updateFonts()
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var key:String?
        var value:String?
        
        if showSections {
            let keys = Array(sections!.keys).sorted(<)
            key = keys[indexPath.section]
            let values = sections![key!]
            value = values![indexPath.row]
            
        } else {
            key = Array(data!.keys)[indexPath.section]
            let dict = data![key!]
            value = dict![indexPath.row]
        }
        
        var compView:ComprehensiveRulesViewController?
        var bWillPush = true
        
        if value == "Introduction" {
            let path = NSBundle.mainBundle().pathForResource("rules/MagicCompRules_intro", ofType: "htm")
            compView = ComprehensiveRulesViewController(path: path!)
            
        } else if value == "Glossary" {
            var array = [String]()
            
            for child in DTComprehensiveGlossary.MR_findAllSortedBy("term", ascending: true) {
                array.append(child.term)
            }
            compView = ComprehensiveRulesViewController(data: ["Glossary": array], showSections: true)
        
        } else if value == "Credits" {
            let path = NSBundle.mainBundle().pathForResource("rules/MagicCompRules_credits", ofType: "htm")
            compView = ComprehensiveRulesViewController(path: path!)
        
        } else {
            if key == "Table Of Contents" || key == "Rules" {
                var number:NSString = value!
                var range:NSRange = number.rangeOfString(" ")
                number = number.substringToIndex(range.location-1)
                let rule = DTComprehensiveRule.MR_findFirstByAttribute("number", withValue:number) as! DTComprehensiveRule
                
                if rule.children.count == 0 {
                    bWillPush = false
                    
                } else {
                    var array = [String]()
                    
                    for child in DTComprehensiveRule.MR_findByAttribute("parent.number", withValue:number) {
                        array.append(child.number + ". " + child.rule)
                    }
                    compView = ComprehensiveRulesViewController(data: ["Rules": array], showSections: false)
                }

            } else {
                bWillPush = false
            }
        }
        
        if bWillPush {
            compView!.navigationItem.title = value
            navigationController?.pushViewController(compView!, animated:true)
        }
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }

//    MARK: UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        
        } else {
            return true
        }
    }
    
    /*// MBProgressHUDDelegate
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
    
    // UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if (searchBar.canResignFirstResponder()) {
            searchBar.resignFirstResponder()
        }
        
        let hud = MBProgressHUD(view: self.view)
        self.view.addSubview(hud)
        hud.delegate = self
        hud.showWhileExecuting("doSearch", onTarget: self, withObject: nil, animated: false)
        
#if !DEBUG
        // send to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("Comprehensive Rules Search",
            action: searchBar.text,
            label: "Run",
            value:nil).build())
#endif
    }*/
}
