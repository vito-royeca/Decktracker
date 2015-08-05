//
//  CardListViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 1/18/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

enum CardSortMode: Printable  {
    case ByName
    case ByColor
    case ByType
    case ByRarity
    case ByPrice
    
    var description : String {
        switch self {
        case ByName: return "Name"
        case ByColor: return "Color"
        case ByType: return "Type"
        case ByRarity: return "Rarity"
        case ByPrice: return "Price (Median)"
        }
    }
}

class CardListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MBProgressHUDDelegate {

    let kSearchResultsIdentifier = "kSearchResultsIdentifier"
    
    var viewButton:UIBarButtonItem?
    var sortButton:UIBarButtonItem?
    var tblSets:UITableView?
    var colSets:UICollectionView?
    var sections:Array<[String: [String]]>?
    var sectionIndexTitles:[String]?
    var predicate:NSPredicate?
    var sorters:[RLMSortDescriptor]?
    var viewMode:String?
    var sortMode:CardSortMode?
    var sectionName:String?
    var viewLoadedOnce = true
    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required convenience init(coder aDecoder: NSCoder) {
//        self.init()
//        hidesBottomBarWhenPushed = true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        hidesBottomBarWhenPushed = true
        
        viewButton = UIBarButtonItem(image: UIImage(named: "list.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "viewButtonTapped")
        sortButton = UIBarButtonItem(image: UIImage(named: "generic_sorting.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "sortButtonTapped")
        navigationItem.rightBarButtonItems = [sortButton!, viewButton!]
        
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
        
        self.sortMode = CardSortMode.ByName
        self.sectionName = "sectionNameInitial"
        self.loadData()
        self.viewLoadedOnce = false
#if !DEBUG
        // send the screen to Google Analytics
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: "Set: \(self.navigationItem.title!)")
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
#endif
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
            self.loadData()
        }
        
        ActionSheetStringPicker.showPickerWithTitle("View As",
            rows: [kCardViewModeList, kCardViewModeGrid2x2, kCardViewModeGrid3x3],
            initialSelection: initialSelection,
            doneBlock: doneBlock,
            cancelBlock: nil,
            origin: view)
    }
    
    func sortButtonTapped() {
        var sortOptions:[String]?
        var initialSelection = 0
        
        sortOptions = [CardSortMode.ByName.description, CardSortMode.ByColor.description, CardSortMode.ByType.description, CardSortMode.ByRarity.description, CardSortMode.ByPrice.description]
        
        switch self.sortMode! {
        case .ByName:
            initialSelection = 0
        case .ByColor:
            initialSelection = 1
        case .ByType:
            initialSelection = 2
        case .ByRarity:
            initialSelection = 3
        case .ByPrice:
            initialSelection = 4
        default:
            break
        }
        
        let doneBlock = { (picker: ActionSheetStringPicker?, selectedIndex: NSInteger, selectedValue: AnyObject?) -> Void in
            
            switch selectedIndex {
            case 0:
                self.sortMode = .ByName
                self.sectionName = "sectionNameInitial"
            case 1:
                self.sortMode = .ByColor
                self.sectionName = "sectionColor"
            case 2:
                self.sortMode = .ByType
                self.sectionName = "sectionType"
            case 3:
                self.sortMode = .ByRarity
                self.sectionName = "rarity.name"
            case 4:
                self.sortMode = .ByPrice
                self.sectionName = nil
            default:
                break
            }
            
            self.loadData()
        }
        
        ActionSheetStringPicker.showPickerWithTitle("Sort By",
            rows: sortOptions,
            initialSelection: initialSelection,
            doneBlock: doneBlock,
            cancelBlock: nil,
            origin: view)
    }
    
    func loadData() {
        switch sortMode! {
        case .ByName:
            self.sorters = [RLMSortDescriptor(property: "sectionNameInitial", ascending: true),
                            RLMSortDescriptor(property: "name", ascending: true)]
        case .ByColor:
            self.sorters = [RLMSortDescriptor(property: "sectionColor", ascending: true),
                            RLMSortDescriptor(property: "name", ascending: true)]
            
        case .ByType:
            self.sorters = [RLMSortDescriptor(property: "sectionType", ascending: true),
                            RLMSortDescriptor(property: "name", ascending: true)]
            
        case .ByRarity:
            self.sorters = [RLMSortDescriptor(property: "rarity.name", ascending: true),
                            RLMSortDescriptor(property: "name", ascending: true)]
            
        case .ByPrice:
            self.sorters = [RLMSortDescriptor(property: "tcgPlayerMidPrice", ascending: false),
                            RLMSortDescriptor(property: "name", ascending: true)]
        default:
            break
        }
        
        var view:UIView?
        if self.viewMode == kCardViewModeList {
            view = tblSets
        } else {
            view = colSets
        }
        
        let hud = MBProgressHUD(view: view)
        view!.addSubview(hud)
        hud.delegate = self
        hud.showWhileExecuting("doSearch", onTarget: self, withObject: nil, animated: true)
    }
    
    func doSearch() {
        var unsortedSections = [String: [String]]()
        sections = Array<[String: [String]]>()
        sectionIndexTitles = [String]()
        
        let cards = Database.sharedInstance().findCards(nil, withPredicate:self.predicate, withSortDescriptors: self.sorters, withSectionName:self.sectionName)
        for x in cards {
            if self.sortMode == .ByPrice {
                continue
            }
            
            let card = x as! DTCard
            var name:String?
            var predicate:NSPredicate?
            
            if sectionName == "sectionNameInitial" {
                name = card.sectionNameInitial
            } else if sectionName == "sectionColor" {
                name = card.sectionColor
            } else if sectionName == "sectionType" {
                name = card.sectionType
            } else if sectionName == "rarity.name" {
                name = card.rarity.name
            }
            predicate = NSPredicate(format: "%K = %@", sectionName!, name!)
            
            if (name != nil) {
                var cardIds = Array<String>()
                
                for y in cards.objectsWithPredicate(predicate!) {
                    let z = y as! DTCard
                    cardIds.append(z.cardId)
                }
                
                let index = advance(name!.startIndex, 1)
                var indexTitle = name!.substringToIndex(index)
                
                if name == "Blue" {
                    indexTitle = "U"
                }
                
                unsortedSections.updateValue(cardIds, forKey: name!)
                if !contains(sectionIndexTitles!, indexTitle) {
                    sectionIndexTitles!.append(indexTitle)
                }
            }
        }
        
        for k in unsortedSections.keys.array.sorted(<) {
            let dict = [k: unsortedSections[k]!]
            sections!.append(dict)
        }
        
        if self.viewMode == kCardViewModeList {
            tblSets!.reloadData()
        } else if self.viewMode == kCardViewModeGrid2x2 ||
            self.viewMode == kCardViewModeGrid3x3 {
            colSets!.reloadData()
        }
    }
    
    func showTableView() {
        let y = viewLoadedOnce ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height
        let height = view.frame.size.height - y
        var frame = CGRect(x:0, y:y, width:view.frame.width, height:height)
        
        tblSets = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tblSets!.delegate = self
        tblSets!.dataSource = self
        tblSets!.registerNib(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: kSearchResultsIdentifier)

        if colSets != nil {
            colSets!.removeFromSuperview()
        }
        view.addSubview(tblSets!)
    }
    
    func showGridView() {
        let y = viewLoadedOnce ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height
        let height = view.frame.size.height - y
        let divisor:CGFloat = viewMode == kCardViewModeGrid2x2 ? 2 : 3
        var frame = CGRect(x:0, y:y, width:view.frame.width, height:height)
        
        
        let layout = CSStickyHeaderFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width:view.frame.width, height: 22)
        layout.itemSize = CGSize(width: frame.width/divisor, height: frame.height/divisor)
        
        colSets = UICollectionView(frame: frame, collectionViewLayout: layout)
        colSets!.dataSource = self
        colSets!.delegate = self
        colSets!.registerClass(CardListCollectionViewCell.self, forCellWithReuseIdentifier: "Card")
        colSets!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:"Header")
        colSets!.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/images/Gray_Patterned_BG.jpg")!)
        
        if tblSets != nil {
            tblSets!.removeFromSuperview()
        }
        view.addSubview(colSets!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    MARK: UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(SEARCH_RESULTS_CELL_HEIGHT)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = sections![section]
        let key = dict.keys.array[0]
        return dict[key]!.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.sortMode == CardSortMode.ByPrice) {
            return nil
            
        } else {
            let dict = sections![section]
            let key = dict.keys.array[0]
            let cardIds = dict[key]
            let cardsString = cardIds!.count > 1 ? "cards" : "card"
            return "\(key) (\(cardIds!.count) \(cardsString))"
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
//        var section = -1
//        
//        let keys = Array(sections!.keys)//.sorted(<)
//        
//        for (i, value) in enumerate(keys) {
//            if (value == "Blue" && title == "U") {
//                section = i
//                break
//                
//            } else {
//                if value.hasPrefix(title) {
//                    section = i
//                    break
//                }
//            }
//        }
//        
//        return section
        
        return index
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dict = sections![indexPath.section]
        let key = dict.keys.array[0]
        let cardIds = dict[key]
        let cardId = cardIds![indexPath.row]
        let cell:SearchResultsTableViewCell?
        
        if let x = tableView.dequeueReusableCellWithIdentifier(kSearchResultsIdentifier) as? SearchResultsTableViewCell {
            cell = x
        } else {
            cell = SearchResultsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kSearchResultsIdentifier)
        }
        
        cell!.accessoryType = UITableViewCellAccessoryType.None
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.displayCard(cardId)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict = sections![indexPath.section]
        var key = dict.keys.array[0]
        var cardIds = dict[key]
        var cardId = cardIds![indexPath.row]
        let card = DTCard(forPrimaryKey: cardId)

        let iaps = Database.sharedInstance().inAppSettingsForSet(card!.set.setId)
        if iaps != nil {
            return
        }
        
        cardIds = Array()
        for d in sections! {
            key = d.keys.array[0]
            for cardId in d[key]! {
                cardIds!.append(cardId)
            }
        }
        
        let view = CardDetailsViewController()
        view.addButtonVisible = true
        view.cardIds = cardIds
        view.cardId = cardId
        
        self.navigationController?.pushViewController(view, animated:true)
    }
    
//    MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections!.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dict = sections![section]
        let key = dict.keys.array[0]
        return dict[key]!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dict = sections![indexPath.section]
        let key = dict.keys.array[0]
        let cardIds = dict[key]
        let cardId = cardIds![indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Card", forIndexPath: indexPath) as! CardListCollectionViewCell

        cell.displayCard(cardId)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var view:UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            if (self.sortMode == CardSortMode.ByPrice) {
                
            } else {
                let dict = sections![indexPath.section]
                let key = dict.keys.array[0]
                let cardIds = dict[key]
//                let key = sections!.keys.array[indexPath.section]
//                let cardIds = sections![key]
                let cardsString = cardIds!.count > 1 ? "cards" : "card"
                let text =  "  \(key) (\(cardIds!.count) \(cardsString))"
                
                let label = UILabel(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height:22))
                label.text = text
                label.backgroundColor = UIColor.whiteColor()
                label.font = UIFont.boldSystemFontOfSize(18)
                
                view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:"Header", forIndexPath:indexPath) as? UICollectionReusableView
                
                if view == nil {
                    view = UICollectionReusableView(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height:22))
                }
                view!.addSubview(label)
            }
        }
        
        return view!
    }

//    MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let dict = sections![indexPath.section]
        var key = dict.keys.array[0]
        var cardIds = dict[key]
        var cardId = cardIds![indexPath.row]
        let card = DTCard(forPrimaryKey: cardId)
        
        let iaps = Database.sharedInstance().inAppSettingsForSet(card!.set.setId)
        if iaps != nil {
            return
        }
        
        cardIds = Array()
        for d in sections! {
            key = d.keys.array[0]
            for cardId in d[key]! {
                cardIds!.append(cardId)
            }
        }
        
        let view = CardDetailsViewController()
        view.addButtonVisible = true
        view.cardIds = cardIds
        view.cardId = cardId
        
        self.navigationController?.pushViewController(view, animated:true)
    }

//    MARK: MBProgressHUDDelegate methods
    func hudWasHidden(hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
}
