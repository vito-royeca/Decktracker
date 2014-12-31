//
//  StartingHandViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/30/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

enum ViewMode: Printable  {
    case ByHand
    case ByGraveyard
    case ByLibrary
    
    var description : String {
        switch self {
            case ByHand: return "Hand"
            case ByGraveyard: return "Graveyard"
            case ByLibrary: return "Library"
        }
    }
}

class StartingHandViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let kSearchResultsIdentifier = "kSearchResultsIdentifier"
    var initialHand = 7

    var viewButton:UIBarButtonItem?
    var newButton:UIBarButtonItem?
    var mulliganButton:UIBarButtonItem?
    var drawButton:UIBarButtonItem?
    var tblHand:UITableView?
    var bottomToolbar:UIToolbar?
    var viewMode:ViewMode?
    var deck:Deck?
    var arrayDeck:[DTCard]?
    var arrayHand:[DTCard]?
    var arrayGraveyard:[DTCard]?
    var arrayLibrary:[DTCard]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        var dX:CGFloat = 0
        var dY:CGFloat = 0
        var dWidth = self.view.frame.size.width
        var dHeight = self.view.frame.size.height-44
        var frame:CGRect?
        
        viewButton = UIBarButtonItem(title: "View", style: UIBarButtonItemStyle.Plain, target: self, action: "viewButtonTapped")
        newButton = UIBarButtonItem(title: "New Hand", style: UIBarButtonItemStyle.Plain, target: self, action: "newButtonTapped")
        mulliganButton = UIBarButtonItem(title: "Mulligan", style: UIBarButtonItemStyle.Plain, target: self, action: "mulliganButtonTapped")
        drawButton = UIBarButtonItem(title: "Draw", style: UIBarButtonItemStyle.Plain, target: self, action: "drawButtonTapped")
        
        frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        tblHand = UITableView(frame: frame!, style: UITableViewStyle.Plain)
        tblHand!.delegate = self
        tblHand!.dataSource = self
        tblHand!.registerNib(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: kSearchResultsIdentifier)
        
        dY = dHeight
        dHeight = 44
        frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        bottomToolbar = UIToolbar(frame: frame!)
        bottomToolbar!.items = [newButton!,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                                mulliganButton!,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                                drawButton!]
        
        view.addSubview(tblHand!)
        view.addSubview(bottomToolbar!)
        
        self.navigationItem.title = "Starting Hand"
        self.navigationItem.rightBarButtonItem = viewButton
        self.newButtonTapped()
        
#if !DEBUG
        // send the screen to Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Starting Hand")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func hidesBottomBarWhenPushed() -> Bool {
        return true
    }
    
    func viewButtonTapped() {
        var initialSelection = 0
        
        switch self.viewMode! {
            case .ByHand:
                initialSelection = 0
            case .ByGraveyard:
                initialSelection = 1
            case .ByLibrary:
                initialSelection = 2
            default:
                break
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            
            switch selectedIndex {
            case 0:
                self.viewMode = .ByHand
            case 1:
                self.viewMode = .ByGraveyard
            case 2:
                self.viewMode = .ByLibrary
            default:
                break
            }
            
            
            self.tblHand!.reloadData()
        }
        
        ActionSheetStringPicker.showPickerWithTitle("View Cards In",
            rows: [ViewMode.ByHand.description, ViewMode.ByGraveyard.description, ViewMode.ByLibrary.description],
            initialSelection: initialSelection,
            doneBlock: doneBlock,
            cancelBlock: nil,
            origin: view)
    }

    func newButtonTapped() {
        initialHand = 7
        self.mulliganButton!.enabled = true
        
        arrayHand = Array()
        arrayGraveyard = Array()
        arrayLibrary = Array()
        self.initDeck()
        self.shuffleLibrary()
        self.drawCards(initialHand)

        self.viewMode = ViewMode.ByHand
        self.tblHand!.reloadData()
    }
    
    func mulliganButtonTapped() {
        initialHand -= 1
        if initialHand <= 1 {
            self.mulliganButton!.enabled = false
        }
        
        // put cards from hand to library
        while arrayHand!.count > 0 {
            let card = arrayHand!.removeLast()
            arrayLibrary!.append(card)
        }
        
        // put cards from graveyard to library
        while arrayGraveyard!.count > 0 {
            let card = arrayGraveyard!.removeLast()
            arrayLibrary!.append(card)
        }
        
        self.shuffleLibrary()
        self.drawCards(initialHand)
        
        self.viewMode = ViewMode.ByHand
        self.tblHand!.reloadData()
    }
    
    func drawButtonTapped() {
        self.drawCards(1)
        self.viewMode = ViewMode.ByHand
        self.tblHand!.reloadData()
    }
    
    func initDeck() {
        arrayDeck = Array()

        for dict in self.deck!.arrLands {
            let card = dict["card"] as DTCard
            let qty = dict["qty"] as NSNumber
            
            for var i=0; i<qty.integerValue; i++ {
                arrayDeck!.append(card)
            }
        }
        
        for dict in self.deck!.arrCreatures {
            let card = dict["card"] as DTCard
            let qty = dict["qty"] as NSNumber
            
            for var i=0; i<qty.integerValue; i++ {
                arrayDeck!.append(card)
            }
        }
        
        for dict in self.deck!.arrOtherSpells {
            let card = dict["card"] as DTCard
            let qty = dict["qty"] as NSNumber
            
            for var i=0; i<qty.integerValue; i++ {
                arrayDeck!.append(card)
            }
        }
    }

    func shuffleLibrary() {
        var arrayTemp = [DTCard]()
        
        // put cards from deck to library
        while arrayDeck!.count > 0 {
            let card = arrayDeck!.removeLast()
            arrayLibrary!.append(card)
        }
        
        // put cards from library to temp
        while arrayLibrary!.count > 0 {
            var count = UInt32(arrayLibrary!.count)
            var random = Int(arc4random_uniform(count))
            let card = arrayLibrary!.removeAtIndex(random)
            arrayTemp.append(card)
        }
        
        // put cards from temp to library
        while arrayTemp.count > 0 {
            let card = arrayTemp.removeLast()
            arrayLibrary!.append(card)
        }
    }
    
    func drawCards(howMany: Int) {
        for var i=0; i<howMany; i++ {
            if arrayLibrary!.count <= 0 {
                return
            }
            
            let card = arrayLibrary!.removeLast()
            arrayHand!.append(card)
        }
    }
    
    func discardCard(index: Int) {
        let card = arrayHand!.removeAtIndex(index)
        arrayGraveyard!.append(card)
        self.tblHand!.reloadData()
    }
    
    // UITableViewDataSource
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var count = 0
        
        switch self.viewMode! {
            case .ByHand:
                count = self.arrayHand!.count
            
            case .ByGraveyard:
                count = self.arrayGraveyard!.count
            
            case .ByLibrary:
                count = self.arrayLibrary!.count
        }
        
        return "Cards In \(self.viewMode!.description): \(count)"
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(SEARCH_RESULTS_CELL_HEIGHT)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.viewMode! {
            case .ByHand:
                return self.arrayHand!.count
            
        case .ByGraveyard:
            return self.arrayGraveyard!.count
            
        case .ByLibrary:
            return self.arrayLibrary!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        var card:DTCard?
        
        switch self.viewMode! {
            case .ByHand:
                if (self.arrayHand!.count > 0) {
                    card = self.arrayHand![indexPath.row]
                }
            
            case .ByGraveyard:
                if (self.arrayGraveyard!.count > 0) {
                    card = self.arrayGraveyard![indexPath.row]
            }
            
            case .ByLibrary:
                if (self.arrayLibrary!.count > 0) {
                    card = self.arrayLibrary![indexPath.row]
            }
        }
        
        var cell1 = tableView.dequeueReusableCellWithIdentifier(kSearchResultsIdentifier) as SearchResultsTableViewCell?
        if cell1 == nil {
            cell1 = SearchResultsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kSearchResultsIdentifier)
        }
            
        cell1!.accessoryType = UITableViewCellAccessoryType.None
        cell1!.selectionStyle = UITableViewCellSelectionStyle.None
        cell1!.displayCard(card)
        cell = cell1;
        
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return self.viewMode == .ByHand
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Discard"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.discardCard(indexPath.row)
    }
}
