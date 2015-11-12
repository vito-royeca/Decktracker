//
//  StartingHandViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 12/30/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

import UIKit

enum StartingHandShowMode: CustomStringConvertible  {
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

class StartingHandViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var initialHand = 7

    var viewButton:UIBarButtonItem?
    var showButton:UIBarButtonItem?
    var newButton:UIBarButtonItem?
    var mulliganButton:UIBarButtonItem?
    var drawButton:UIBarButtonItem?
    var tblHand:UITableView?
    var colHand:UICollectionView?
    var bottomToolbar:UIToolbar?
    var viewMode:String?
    var showMode:StartingHandShowMode?
    var deck:Deck?
    var arrayDeck:[String]?
    var arrayHand:[String]?
    var arrayGraveyard:[String]?
    var arrayLibrary:[String]?
    var viewLoadedOnce = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hidesBottomBarWhenPushed = true

        let dX:CGFloat = 0
        var dY:CGFloat = 0
        let dWidth = self.view.frame.size.width
        var dHeight = self.view.frame.size.height-44
        var frame:CGRect?
        
        viewButton = UIBarButtonItem(image: UIImage(named: "list.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "viewButtonTapped")
        showButton = UIBarButtonItem(image: UIImage(named: "view_file.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "showButtonTapped")
        
        newButton = UIBarButtonItem(title: "New Hand", style: UIBarButtonItemStyle.Plain, target: self, action: "newButtonTapped")
        mulliganButton = UIBarButtonItem(title: "Mulligan", style: UIBarButtonItemStyle.Plain, target: self, action: "mulliganButtonTapped")
        drawButton = UIBarButtonItem(title: "Draw", style: UIBarButtonItemStyle.Plain, target: self, action: "drawButtonTapped")
        
        dY = dHeight
        dHeight = 44
        frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        bottomToolbar = UIToolbar(frame: frame!)
        bottomToolbar!.items = [newButton!,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                                mulliganButton!,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                                drawButton!]

        
        self.navigationItem.title = "Starting Hand"
        self.navigationItem.rightBarButtonItems = [showButton!, viewButton!]
        
        if let value = NSUserDefaults.standardUserDefaults().stringForKey(kCardViewMode) {
            if value == kCardViewModeList {
                self.viewMode = kCardViewModeList
                self.showTableView()
                
            } else if value == kCardViewModeGrid2x2 {
                self.viewMode = kCardViewModeGrid2x2
                viewButton!.image = UIImage(named: "2x2.png")
                self.showGridView()
                
            } else if value == kCardViewModeGrid3x3 {
                self.viewMode = kCardViewModeGrid3x3
                viewButton!.image = UIImage(named: "3x3.png")
                self.showGridView()
                
            } else {
                self.viewMode = kCardViewModeList
                self.showTableView()
            }
            
        } else {
            self.viewMode = kCardViewModeList
            self.showTableView()
        }
        
        view.addSubview(bottomToolbar!)
        self.viewLoadedOnce = false
        self.newButtonTapped()
        
#if !DEBUG
        // send the screen to Google Analytics
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: "Starting Hand")
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewButtonTapped() {
        var initialSelection = 0
        
        if self.viewMode == kCardViewModeList {
            initialSelection = 0
        } else if self.viewMode == kCardViewModeGrid2x2 {
            initialSelection = 1
        } else if self.viewMode == kCardViewModeGrid3x3 {
            initialSelection = 2
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            
            switch selectedIndex {
            case 0:
                self.viewMode = kCardViewModeList
                self.viewButton!.image = UIImage(named: "list.png")
                self.showTableView()
            case 1:
                self.viewMode = kCardViewModeGrid2x2
                self.viewButton!.image = UIImage(named: "2x2.png")
                self.showGridView()
            case 2:
                self.viewMode = kCardViewModeGrid3x3
                self.viewButton!.image = UIImage(named: "3x3.png")
                self.showGridView()
            default:
                break
            }
            
            NSUserDefaults.standardUserDefaults().setObject(self.viewMode, forKey: kCardViewMode)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        ActionSheetStringPicker.showPickerWithTitle("View As",
            rows: [kCardViewModeList, kCardViewModeGrid2x2, kCardViewModeGrid3x3],
            initialSelection: initialSelection,
            doneBlock: doneBlock,
            cancelBlock: nil,
            origin: view)
    }
    
    func showButtonTapped() {
        var initialSelection = 0
        
        switch self.showMode! {
            case .ByHand:
                initialSelection = 0
            case .ByGraveyard:
                initialSelection = 1
            case .ByLibrary:
                initialSelection = 2
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            
            switch selectedIndex {
            case 0:
                self.showMode = .ByHand
            case 1:
                self.showMode = .ByGraveyard
            case 2:
                self.showMode = .ByLibrary
            default:
                break
            }
            
            if self.viewMode == kCardViewModeList {
                self.tblHand!.reloadData()
            } else if self.viewMode == kCardViewModeGrid2x2 ||
                self.viewMode == kCardViewModeGrid3x3 {
                self.colHand!.reloadData()
            } else if self.viewMode == kCardViewModeGrid3x3 {
                initialSelection = 2
            }
        }
        
        ActionSheetStringPicker.showPickerWithTitle("Show Cards In",
            rows: [StartingHandShowMode.ByHand.description, StartingHandShowMode.ByGraveyard.description, StartingHandShowMode.ByLibrary.description],
            initialSelection: initialSelection,
            doneBlock: doneBlock,
            cancelBlock: nil,
            origin: view)
    }

    func newButtonTapped() {
        initialHand = 7
        self.mulliganButton!.enabled = true
        self.drawButton!.enabled = true
        
        arrayHand = Array()
        arrayGraveyard = Array()
        arrayLibrary = Array()
        self.initDeck()
        self.shuffleLibrary()
        self.drawCards(initialHand)

        self.showMode = StartingHandShowMode.ByHand
        
        if self.viewMode == kCardViewModeList {
            tblHand!.reloadData()
        } else if self.viewMode == kCardViewModeGrid2x2 ||
            self.viewMode == kCardViewModeGrid3x3 {
                colHand!.reloadData()
        }
    }
    
    func mulliganButtonTapped() {
        initialHand -= 1
        if initialHand <= 1 {
            self.mulliganButton!.enabled = false
        }
        
        // put cards from hand to library
        while arrayHand!.count > 0 {
            let cardId = arrayHand!.removeLast()
            arrayLibrary!.append(cardId)
        }
        
        // put cards from graveyard to library
        while arrayGraveyard!.count > 0 {
            let cardId = arrayGraveyard!.removeLast()
            arrayLibrary!.append(cardId)
        }
        
        self.shuffleLibrary()
        self.drawCards(initialHand)
        self.showMode = StartingHandShowMode.ByHand
        
        if self.viewMode == kCardViewModeList {
            tblHand!.reloadData()
        } else if self.viewMode == kCardViewModeGrid2x2 ||
            self.viewMode == kCardViewModeGrid3x3 {
                colHand!.reloadData()
        }
    }
    
    func drawButtonTapped() {
        if arrayLibrary!.count <= 0 {
            self.drawButton!.enabled = false
        }
        self.drawCards(1)
        self.showMode = StartingHandShowMode.ByHand
        
        if self.viewMode == kCardViewModeList {
            tblHand!.reloadData()
        } else if self.viewMode == kCardViewModeGrid2x2 ||
            self.viewMode == kCardViewModeGrid3x3{
                colHand!.reloadData()
        }
    }
    
    func showTableView() {
        let dX:CGFloat = 0
        let dY = viewLoadedOnce ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height
        let dWidth = self.view.frame.size.width
        let dHeight = self.view.frame.size.height-dY-44
        let frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        
        tblHand = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblHand!.delegate = self
        tblHand!.dataSource = self
        
        if colHand != nil {
            colHand!.removeFromSuperview()
        }
        view.addSubview(tblHand!)
    }
    
    func showGridView() {
        let dX:CGFloat = 0
        let dY = viewLoadedOnce ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height
        let dWidth = self.view.frame.size.width
        let dHeight = self.view.frame.size.height-dY-44
        let frame = CGRect(x:dX, y:dY, width:dWidth, height:dHeight)
        let divisor:CGFloat = viewMode == kCardViewModeGrid2x2 ? 2 : 3
        
        let layout = CSStickyHeaderFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width:view.frame.width, height: 22)
        layout.itemSize = CGSize(width: frame.width/divisor, height: frame.height/divisor)
        
        colHand = UICollectionView(frame: frame, collectionViewLayout: layout)
        colHand!.dataSource = self
        colHand!.delegate = self
        colHand!.registerClass(CardImageCollectionViewCell.self, forCellWithReuseIdentifier: "Card")
        colHand!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:"Header")
        colHand!.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)
        
        if tblHand != nil {
            tblHand!.removeFromSuperview()
        }
        view.addSubview(colHand!)
    }
    
    func initDeck() {
        arrayDeck = Array()

        for dict in self.deck!.arrLands {
            let d = dict as! Dictionary<String, AnyObject>
            let cardId = d["cardId"] as! String
//            let card = DTCard(forPrimaryKey: cardId)
            let qty = d["qty"] as! NSNumber
            
            for var i=0; i<qty.integerValue; i++ {
                arrayDeck!.append(cardId)
            }
        }
        
        for dict in self.deck!.arrCreatures {
            let d = dict as! Dictionary<String, AnyObject>
            let cardId = d["cardId"] as! String
//            let card = DTCard(forPrimaryKey: cardId)
            let qty = d["qty"] as! NSNumber
            
            for var i=0; i<qty.integerValue; i++ {
                arrayDeck!.append(cardId)
            }
        }
        
        for dict in self.deck!.arrOtherSpells {
            let d = dict as! Dictionary<String, AnyObject>
            let cardId = d["cardId"] as! String
//            let card = DTCard(forPrimaryKey: cardId)
            let qty = d["qty"] as! NSNumber
            
            for var i=0; i<qty.integerValue; i++ {
                arrayDeck!.append(cardId)
            }
        }
    }

    func shuffleLibrary() {
        var arrayTemp = [String]()
        
        // put cards from deck to library
        while arrayDeck!.count > 0 {
            let cardId = arrayDeck!.removeLast()
            arrayLibrary!.append(cardId)
        }
        
        // put cards from library to temp
        while arrayLibrary!.count > 0 {
            let count = UInt32(arrayLibrary!.count)
            let random = Int(arc4random_uniform(count))
            let cardId = arrayLibrary!.removeAtIndex(random)
            arrayTemp.append(cardId)
        }
        
        // put cards from temp to library
        while arrayTemp.count > 0 {
            let cardId = arrayTemp.removeLast()
            arrayLibrary!.append(cardId)
        }
    }
    
    func drawCards(howMany: Int) {
        for var i=0; i<howMany; i++ {
            if arrayLibrary!.count <= 0 {
                return
            }
            
            let cardId = arrayLibrary!.removeLast()
            arrayHand!.append(cardId)
        }
    }
    
    func discardCard(index: Int) {
        let cardId = arrayHand!.removeAtIndex(index)
        arrayGraveyard!.append(cardId)
        
        if self.viewMode == kCardViewModeList {
            tblHand!.reloadData()
        } else if self.viewMode == kCardViewModeGrid2x2 ||
            self.view == kCardViewModeGrid3x3{
                colHand!.reloadData()
        }
    }
    
//    MARK: UITableViewDataSource
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var count = 0
        
        switch self.showMode! {
            case .ByHand:
                count = self.arrayHand!.count
            
            case .ByGraveyard:
                count = self.arrayGraveyard!.count
            
            case .ByLibrary:
                count = self.arrayLibrary!.count
        }
        
        return "Cards In \(self.showMode!.description): \(count)"
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(CARD_SUMMARY_VIEW_CELL_HEIGHT)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.showMode! {
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
        var cardSummaryView:CardSummaryView?
        var cardId:String?
        
        switch self.showMode! {
            case .ByHand:
                if (self.arrayHand!.count > 0) {
                    cardId = self.arrayHand![indexPath.row]
                }
            
            case .ByGraveyard:
                if (self.arrayGraveyard!.count > 0) {
                    cardId = self.arrayGraveyard![indexPath.row]
            }
            
            case .ByLibrary:
                if (self.arrayLibrary!.count > 0) {
                    cardId = self.arrayLibrary![indexPath.row]
            }
        }
        
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return self.showMode == .ByHand
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Discard"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.discardCard(indexPath.row)
    }
    
//    MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.showMode! {
        case .ByHand:
            return self.arrayHand!.count
            
        case .ByGraveyard:
            return self.arrayGraveyard!.count
            
        case .ByLibrary:
            return self.arrayLibrary!.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cardId:String?
        
        switch self.showMode! {
        case .ByHand:
            if (self.arrayHand!.count > 0) {
                cardId = self.arrayHand![indexPath.row]
            }
            
        case .ByGraveyard:
            if (self.arrayGraveyard!.count > 0) {
                cardId = self.arrayGraveyard![indexPath.row]
            }
            
        case .ByLibrary:
            if (self.arrayLibrary!.count > 0) {
                cardId = self.arrayLibrary![indexPath.row]
            }
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Card", forIndexPath: indexPath) as! CardImageCollectionViewCell
        
        cell.displayCard(cardId!, cropped: false, showName: false, showSetIcon: false)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var view:UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            var count = 0
            
            switch self.showMode! {
            case .ByHand:
                count = self.arrayHand!.count
                
            case .ByGraveyard:
                count = self.arrayGraveyard!.count
                
            case .ByLibrary:
                count = self.arrayLibrary!.count
            }
            
            let text = "  Cards In \(self.showMode!.description): \(count)"
            let label = UILabel(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height:22))
            label.text = text
            label.backgroundColor = UIColor.whiteColor()
            label.font = UIFont.boldSystemFontOfSize(18)
            
            view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:"Header", forIndexPath:indexPath) as UICollectionReusableView!
            
            if view == nil {
                view = UICollectionReusableView(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height:22))
            }
            view!.addSubview(label)
        }
        
        return view!
    }
}
