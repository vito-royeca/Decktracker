//
//  LimitedSearchViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 6/9/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class LimitedSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate
{
    var deckName:String?
    var searchBar:UISearchBar?
    var tblResults:UITableView?
    var predicate:NSPredicate?
    var sections:Array<[String: [String]]>?
    var sectionIndexTitles:[String]?
    var sectionName:String?
    var viewLoadedOnce = true
    var searchTimer:NSTimer?
    var placeHolderTitle:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dX = CGFloat(0)
        let dY = CGFloat(0)
        let dWidth = self.view.frame.size.width
        let dHeight = self.view.frame.size.height
        self.searchBar = UISearchBar()
        self.searchBar!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.searchBar!.delegate = self;
        // Add a Done button in the keyboard
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self.searchBar, action: "resignFirstResponder")
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, dWidth, 44))
        toolbar.items = [barButton]
        self.searchBar!.inputAccessoryView = toolbar
        self.searchBar!.placeholder = placeHolderTitle;
        
        self.tblResults = UITableView(frame: CGRectMake(dX, dY, dWidth, dHeight), style: UITableViewStyle.Plain)
        self.tblResults!.delegate = self
        self.tblResults!.dataSource = self

        self.navigationItem.titleView = self.searchBar;
        self.view.addSubview(self.tblResults!)
        
        self.sectionName = "sectionNameInitial"
        sections = Array<[String: [String]]>()
        sectionIndexTitles = [String]()
        self.viewLoadedOnce = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadData() {
        let hud = MBProgressHUD(view: view)
        view!.addSubview(hud)
        hud.delegate = self
        hud.showWhileExecuting("doSearch", onTarget: self, withObject: nil, animated: true)
    }
    
    func doSearch() {
        var unsortedSections = [String: [String]]()
        sections = Array<[String: [String]]>()
        sectionIndexTitles = [String]()
        
        let cards = Database.sharedInstance().findCards(self.searchBar!.text, withPredicate:self.predicate, withSortDescriptors: [RLMSortDescriptor(property: "name", ascending: true)], withSectionName:sectionName)
        for x in cards {
            let card = x as! DTCard
            let name = card.sectionNameInitial
            let predicate = NSPredicate(format: "%K = %@", sectionName!, name!)
            
            if (name != nil) {
                var cardIds = Array<String>()
                
                for y in cards.objectsWithPredicate(predicate) {
                    let z = y as! DTCard
                    cardIds.append(z.cardId)
                }
                
                let index = name!.startIndex.advancedBy(1)
                var indexTitle = name!.substringToIndex(index)
                
                if name == "Blue" {
                    indexTitle = "U"
                }
                
                unsortedSections.updateValue(cardIds, forKey: name!)
                if !sectionIndexTitles!.contains(indexTitle) {
                    sectionIndexTitles!.append(indexTitle)
                }
            }
        }
        
        for k in unsortedSections.keys.sort(<) {
            let dict = [k: unsortedSections[k]!]
            sections!.append(dict)
        }
        
        self.tblResults!.reloadData()
    }
    
//    MARK: UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchTimer != nil && searchTimer!.valid {
            searchTimer!.invalidate()
        }
        searchTimer = NSTimer(timeInterval: 1.0, target: self, selector: "handleSearchBarEndTyping", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(searchTimer!, forMode:NSDefaultRunLoopMode)

    }
    
    func handleSearchBarEndTyping() {
        let hud = MBProgressHUD(view: view)
        view!.addSubview(hud)
        hud.delegate = self;
        
        if searchBar!.text!.isEmpty {
            sections = Array<[String: [String]]>()
            sectionIndexTitles = [String]()
            self.tblResults!.reloadData()
            
        } else {
            hud.showWhileExecuting("loadData", onTarget: self, withObject: nil, animated: true)
        }
    }
    
//    MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(CARD_SUMMARY_VIEW_CELL_HEIGHT)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict = sections![indexPath.section]
        let key = dict.keys.first
        var cardIds = dict[key!]
        let cardId = cardIds![indexPath.row]
        
        let view = AddCardViewController()
        view.arrDecks = NSMutableArray(array: [self.deckName!])
        view.cardId = cardId;
        view.createButtonVisible = false
        view.showCardButtonVisible = true
        view.segmentedControlIndex = 0;
        self.navigationController!.pushViewController(view, animated: true)
    }

//    MARK : UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dict = sections![section]
        let key = dict.keys.first
        let cardIds = dict[key!]
        let cardsString = cardIds!.count > 1 ? "cards" : "card"
        return "\(key) (\(cardIds!.count) \(cardsString))"
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = sections![section]
        let key = dict.keys.first
        return dict[key!]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dict = sections![indexPath.section]
        let key = dict.keys.first
        let cardIds = dict[key!]
        let cardId = cardIds![indexPath.row]
        var cell:UITableViewCell?
        var cardSummaryView:CardSummaryView?
        
        if let x = tableView.dequeueReusableCellWithIdentifier(kCardInfoViewIdentifier) as UITableViewCell! {
            cell = x
            for subView in cell!.contentView.subviews {
                if subView is CardSummaryView {
                    cardSummaryView = subView as? CardSummaryView
                    break
                }
            }
            
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kCardInfoViewIdentifier)
            cardSummaryView = NSBundle.mainBundle().loadNibNamed("CardSummaryView", owner: self, options: nil).first as? CardSummaryView
            cardSummaryView!.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: CGFloat(CARD_SUMMARY_VIEW_CELL_HEIGHT))
            cell!.contentView.addSubview(cardSummaryView!)
        }
        
        cell!.accessoryType = UITableViewCellAccessoryType.None
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cardSummaryView!.displayCard(cardId)
        
        return cell!
    }
    
//    MARK: MBProgressHUDDelegate methods
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }

}
