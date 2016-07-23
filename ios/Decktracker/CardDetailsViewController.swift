//
//  CardDetailsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 16/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import SafariServices

class CardDetailsViewController: UIViewController {

    // MARK: Variables
    var cardOID:NSManagedObjectID?
    var swiperFetchRequest:NSFetchRequest?
    
    private var _setsFetchRequest:NSFetchRequest? = nil
    var setsFetchRequest:NSFetchRequest? {
        get {
            return _setsFetchRequest
        }
        set (aNewValue) {
            
            if (_setsFetchRequest != aNewValue) {
                _setsFetchRequest = aNewValue
                
                // force reset the fetchedResultsController
                if let _setsFetchRequest = _setsFetchRequest {
                    let context = CoreDataManager.sharedInstance.mainObjectContext
                    _setsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "set.releaseDate", ascending: true)]
                    setsFetchedResultsController = NSFetchedResultsController(fetchRequest: _setsFetchRequest,
                                                                          managedObjectContext: context,
                                                                          sectionNameKeyPath: nil,
                                                                          cacheName: nil)
                }
            }
        }
    }
    lazy var setsFetchedResultsController: NSFetchedResultsController = {
        let context = CoreDataManager.sharedInstance.mainObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: self.setsFetchRequest!,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerNib(UINib(nibName: "CardSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "summaryCell")
        tableView.registerNib(UINib(nibName: "PricingTableViewCell", bundle: nil), forCellReuseIdentifier: "pricingCell")
        tableView.registerNib(UINib(nibName: "CardImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imageCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "numberCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "textsCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "artistCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "legalitiesCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "rulingsCell")
        tableView.registerNib(UINib(nibName: "CardSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "setsCell")
        tableView.registerNib(UINib(nibName: "CardSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "variationsCell")

        loadSets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
        
        if segue.identifier == "showCardTexts" {
            if let detailsVC = segue.destinationViewController as? BrowserViewController {
                var html:String?
                var text = ""
                
                do {
                    try html = String(contentsOfFile: "\(NSBundle.mainBundle().bundlePath)/web/cardtext.html", encoding: NSUTF8StringEncoding)
                } catch {}
                
                if let oracleText = card.text {
                    text += "<div class='detailHeader'>Oracle Text</div>"
                    text += "<p>\(replaceSymbolsInText(oracleText))</p>"
                }
                if let originalText = card.originalText {
                    text += "<div class='detailHeader'>Original Text</div>"
                    text += "<p><div class='originalText'>\(replaceSymbolsInText(originalText))</div></p>"
                }
                if let flavorText = card.flavor {
                    text += "<div class='detailHeader'>Flavor Text</div>"
                    text += "<p><div class='flavorText'>\(flavorText)</div></p>"
                }
                html = html!.stringByReplacingOccurrencesOfString("{{text}}", withString: text)
                
                detailsVC.toolBarHidden = true
                detailsVC.navigationTitle = "Card Texts"
                detailsVC.html = html
            }
            
        } else if segue.identifier == "showArtistWiki" {
            if let detailsVC = segue.destinationViewController as? ArtistViewController {
                detailsVC.artistOID = card.artist!.objectID
            }
        
        } else if segue.identifier == "showLegalities" {
            if let detailsVC = segue.destinationViewController as? LegalitiesViewController {
                detailsVC.cardOID = cardOID
            }
        
        } else if segue.identifier == "showRulings" {
            if let detailsVC = segue.destinationViewController as? RulingsViewController {
                detailsVC.cardOID = cardOID
            }
        }
    }
    
    // MARK: Custom methods
    func loadSets() {
        let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
        let sorters = [NSSortDescriptor(key: "set.releaseDate", ascending: true)]
        
        setsFetchRequest = NSFetchRequest(entityName: "Card")
        setsFetchRequest!.predicate = NSPredicate(format: "name == %@ AND cardID != %@ AND set.code != %@", card.name!, card.cardID!, card.set!.code!)
        setsFetchRequest!.sortDescriptors = sorters
        
        do {
            try setsFetchedResultsController.performFetch()
        } catch {}
        setsFetchedResultsController.delegate = self
        
        tableView.reloadData()
    }

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        cell.accessoryType = .None
        cell.selectionStyle = .None
        cell.accessoryView = nil
        
        let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if let c = cell as? CardSummaryTableViewCell {
                    c.cardOID = cardOID
                }
            case 1:
                if let c = cell as? PricingTableViewCell {
                    c.cardOID = cardOID
                    cell.accessoryType = .DisclosureIndicator
                    cell.selectionStyle = .Default
                }
            case 2:
                if let c = cell as? CardImageTableViewCell {
                    c.cardOID = cardOID
                }
            case 3:
                if let number = card.number {
                    cell.textLabel?.text = "Card Number: \(number) / \(card.set!.numberOfCards!)"
                } else {
                    cell.textLabel?.text = "Card Number: "
                }
            case 4:
                cell.textLabel?.text = "Texts"
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Default
            case 5:
                cell.textLabel?.text = card.artist!.name
                cell.detailTextLabel?.text = "Artist"
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Default
            case 6:
                cell.textLabel?.text = "Legalities"
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Default
                if let legalities = card.legalities {
                    addBadgeToCell(cell, count: legalities.allObjects.count)
                }
            case 7:
                cell.textLabel?.text = "Rulings"
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Default
                if let rulings = card.rulings {
                    addBadgeToCell(cell, count: rulings.allObjects.count)
                }
            default:
                ()
            }
        case 1:
            if setsFetchRequest != nil,
                let sections = setsFetchedResultsController.sections,
                let c = cell as? CardSummaryTableViewCell {
                let sectionInfo = sections[indexPath.section-1]
                
                if let objects = sectionInfo.objects {
                    if let card = objects[indexPath.row] as? Card {
                        c.cardOID = card.objectID
                    }
                }
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Default
            }
        case 2:
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
            if let variations = card.variations,
                let c = cell as? CardSummaryTableViewCell {
                
                if variations.count > 0 {
                    if let variation = variations.allObjects[indexPath.row] as? Card {
                        c.cardOID = variation.objectID
                    }
                }
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Default
            }
        default:
            ()
        }
    }
    
    func addBadgeToCell(cell: UITableViewCell, count: Int) {
        let size: CGFloat = 26
        let digits = CGFloat("\(count)".characters.count) // digits in the label
        let width = max(size, 0.7 * size * digits) // perfect circle is smallest allowed
        let badge = UILabel(frame: CGRectMake(0, 0, width, size))
        badge.text = "\(count)"
        badge.layer.cornerRadius = size / 2
        badge.layer.masksToBounds = true
        badge.textAlignment = .Center
        badge.textColor = UIColor.whiteColor()
        badge.backgroundColor = UIColor.redColor()
        cell.accessoryView = badge
    }
    
    func replaceSymbolsInText(text: String) -> String {
        var newText = text
        var arrSymbols = [AnyObject]()
        
        var temp = text.stringByReplacingOccurrencesOfString("{", withString: "")
        temp = temp.stringByReplacingOccurrencesOfString("}", withString: " ")
        temp = JJJUtil.trim(temp)
        arrSymbols = temp.componentsSeparatedByString(" ")
        
        for s in arrSymbols {
            
            let symbol = s as! String
            var noCurlies = symbol.stringByReplacingOccurrencesOfString("/", withString: "")
            let noCurliesReverse = JJJUtil.reverseString(noCurlies)
            
            var bFound = false
            var width:Float = 0.0
            var height:Float = 0.0
            var pngSize = 0
            
            if noCurlies == "100" {
                width = 24.0
                height = 13.0
                pngSize = 48
            } else if noCurlies == "1000000" {
                width = 64.0
                height = 13.0
                pngSize = 96
            } else if noCurlies == "∞" || noCurliesReverse == "∞" {
                noCurlies = "Infinity"
                width = 16.0
                height = 16.0
                pngSize = 32
            } else {
                width = 16.0
                height = 16.0
                pngSize = 32
            }
            
            for mana in Card.ManaSymbols {
                if mana == noCurlies {
                    newText = newText.stringByReplacingOccurrencesOfString("{\(noCurlies)}", withString: "<img src='\(NSBundle.mainBundle().bundlePath)/images/mana/\(noCurlies)/\(pngSize).png' width='\(width)' height='\(height)' />")
                    bFound = true
                } else if mana == noCurliesReverse {
                    newText = newText.stringByReplacingOccurrencesOfString("{\(noCurliesReverse)}", withString: "<img src='\(NSBundle.mainBundle().bundlePath)/images/mana/\(noCurliesReverse)/\(pngSize).png' width='\(width)' height='\(height)' />")
                    bFound = true
                }
            }
            
            if !bFound {
                for mana in Card.OtherSymbols {
                    if mana == noCurlies {
                        newText = newText.stringByReplacingOccurrencesOfString("{\(noCurlies)}", withString: "<img src='\(NSBundle.mainBundle().bundlePath)/images/other/\(noCurlies)/\(pngSize).png' width='\(width)' height='\(height)' />")
                        bFound = true
                    } else if mana == noCurliesReverse {
                        newText = newText.stringByReplacingOccurrencesOfString("{\(noCurliesReverse)}", withString: "<img src='\(NSBundle.mainBundle().bundlePath)/images/other/\(noCurliesReverse)/\(pngSize).png' width='\(width)' height='\(height)' />")
                        bFound = true
                    }
                }
            }
        }
        
        newText = newText.stringByReplacingOccurrencesOfString("(", withString:"(<i>")
        newText = newText.stringByReplacingOccurrencesOfString(")", withString:"</i>)")
        return JJJUtil.stringWithNewLinesAsBRs(newText)
    }
}

// MARK: UITableViewDataSource
extension CardDetailsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 8
        case 1:
            if setsFetchRequest != nil,
                let sections = setsFetchedResultsController.sections {
                let sectionInfo = sections[section-1]
                return sectionInfo.numberOfObjects
                
            } else {
                return 0
            }
        case 2:
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
            if let variations = card.variations {
                return variations.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            if setsFetchRequest != nil,
                let sections = setsFetchedResultsController.sections {
                let sectionInfo = sections[section-1]
                var count = 0
                if let objects = sectionInfo.objects {
                    count = objects.count
                }
                
                return "Other Sets (\(count) \(count > 1 ? "items" : "item"))"
                
            } else {
                return "Other Sets - None"
            }
            
        case 2:
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
            if let variations = card.variations {
                return "Variations (\(variations.count) \(variations.count > 1 ? "items" : "item"))"
            } else {
                return "Variations (0 item)"
            }
            
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath)
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("pricingCell", forIndexPath: indexPath)
            case 2:
                cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath)
            case 3:
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "numberCell")
            case 4:
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "textsCell")
            case 5:
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "artistCell")
            case 6:
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "legalitiesCell")
            case 7:
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "rulingsCell")
            default:
                ()
            }
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("setsCell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("variationsCell", forIndexPath: indexPath)
        default:
            ()
        }
        
        if let cell = cell {
            configureCell(cell, indexPath: indexPath)
        }
        return cell!
    }
}

// MARK: UITableVIewDelegate
extension CardDetailsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0:
                return CardSummaryTableViewCell.CellHeight
            case 1:
                return UITableViewAutomaticDimension
            case 2:
                var height = tableView.frame.size.height -
                    CardSummaryTableViewCell.CellHeight -
                    UITableViewAutomaticDimension -
                    33 // visual clue for the user to scroll down
                
                if let navigationController = navigationController {
                    height -= navigationController.navigationBar.frame.size.height
                }
                return height // - UIApplication.sharedApplication().statusBarFrame.size.height
                
            default:
                return UITableViewAutomaticDimension
            }
        case 1, 2:
            return CardSummaryTableViewCell.CellHeight
            
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 1:
                () // TODO: TCGPlayer pricing
                let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
                if let pricing = card.pricing,
                    let navigationController = navigationController {
                    
                    if let link = pricing.link {
                        if let url = NSURL(string: link) {
                            let svc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
                            svc.delegate = self
                            navigationController.presentViewController(svc, animated: true, completion: nil)
                        }
                    }
                }
                
            case 4:
                performSegueWithIdentifier("showCardTexts", sender: self)
            case 5:
                performSegueWithIdentifier("showArtistWiki", sender: self)
            case 6:
                performSegueWithIdentifier("showLegalities", sender: self)
            case 7:
                performSegueWithIdentifier("showRulings", sender: self)
            default:
                ()
            }
            
        case 1:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CardDetailsViewController") as? CardDetailsViewController,
                let navigationController = navigationController {
                
                let sections = setsFetchedResultsController.sections
                let sectionInfo = sections![indexPath.section-1]
                
                if let objects = sectionInfo.objects {
                    if let card = objects[indexPath.row] as? Card {
                        
                        controller.cardOID = card.objectID
                        navigationController.pushViewController(controller, animated: true)
                    }
                }
            }
            
        case 2:
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
            if let variations = card.variations,
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CardDetailsViewController") as? CardDetailsViewController,
                let navigationController = navigationController {
                
                if variations.count > 0 {
                    if let variation = variations.allObjects[indexPath.row] as? Card {
                        controller.cardOID = variation.objectID
                        navigationController.pushViewController(controller, animated: true)
                    }
                }
            }
            
        default:
            ()
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension CardDetailsViewController : NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        case .Update:
            tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: newIndexPath!.section)], withRowAnimation: .Automatic)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath!.row, inSection: indexPath!.section)], withRowAnimation: .Automatic)
            
        case .Update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    configureCell(cell, indexPath: indexPath)
                }
            }
            
        case .Move:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}

// MARK: SFSafariViewControllerDelegate
extension CardDetailsViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
