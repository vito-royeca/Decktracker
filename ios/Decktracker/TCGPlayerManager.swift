//
//  TCGPlayerManager.swift
//  Decktracker
//
//  Created by Jovit Royeca on 19/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import hpple
import JJJUtils

enum TCGPlayerError: ErrorType {
    case NoAPIKey
}

struct TCGPlayerConstants {
    static let APIURL          = "http://partner.tcgplayer.com/x3/phl.asmx/p"
    static let FetchDelay      = 24*1 // 1 day(s)

}

class TCGPlayerManager: NSObject {

    // MARK: Variables
    private var apiKey:String?
    
    // MARK: Setup
    func setup(apiKey: String) {
        self.apiKey = apiKey
        
    }
    
    // MARK: Shared Instance
    static let sharedInstance = TCGPlayerManager()
    
    // MARK: Custom methods
    func hiMidLowPrices(cardID: String, completion: (cardID: String, error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TCGPlayerError.NoAPIKey
        }
        
        let card = ObjectManager.sharedInstance.findObjects("Card", predicate: NSPredicate(format: "cardID == %@", cardID), sorters: [NSSortDescriptor(key: "name", ascending: true)]).first as! Card

        if needsToFetchTCGPlayerPricing(card) {
            var setName = ""
            if let tcgPlayerName = card.set!.tcgPlayerName {
                setName = tcgPlayerName
            } else {
                setName = card.set!.name
            }
            
            let httpMethod:HTTPMethod = .Get
            let urlString = TCGPlayerConstants.APIURL
            let parameters = ["pk": apiKey!,
                              "s": setName,
                              "p": card.name!]
            
            var dict = [String: AnyObject]()
            
            let success = { (results: AnyObject!) in
                if let data = results as? NSData {
                    let parser = TFHpple(HTMLData: data)
                    var low:String?
                    var mid:String?
                    var high:String?
                    var foil:String?
                    var link:String?
                    
                    let nodes = parser.searchWithXPathQuery("//product")
                    for element in nodes {
                        if element.hasChildren() {
                            var linkIsNext = false
                            
                            for child in element.children {
                                if child.tagName == TCGPlayerPricing.Keys.HighPrice {
                                    if let firstChild = child.firstChild {
                                        high = firstChild.content
                                    }
                                } else if child.tagName == TCGPlayerPricing.Keys.MidPrice {
                                    if let firstChild = child.firstChild {
                                        mid = firstChild.content
                                    }
                                } else if child.tagName == TCGPlayerPricing.Keys.LowPrice {
                                    if let firstChild = child.firstChild {
                                        low = firstChild.content
                                    }
                                } else if child.tagName == TCGPlayerPricing.Keys.FoilPrice {
                                    if let firstChild = child.firstChild {
                                        foil = firstChild.content
                                    }
                                } else if child.tagName == TCGPlayerPricing.Keys.Link {
                                    linkIsNext = true
                                } else if child.tagName == "text" && linkIsNext {
                                    link = child.content
                                }
                            }
                        }
                    }
                    
                    if let low = low {
                        if low != "0" {
                            dict[TCGPlayerPricing.Keys.LowPrice] = NSNumber(double: (low as NSString).doubleValue)
                        }
                    }
                    if let mid = mid {
                        if mid != "0" {
                            dict[TCGPlayerPricing.Keys.MidPrice] = NSNumber(double: (mid as NSString).doubleValue)
                        }
                    }
                    if let high = high {
                        if high != "0" {
                            dict[TCGPlayerPricing.Keys.HighPrice] = NSNumber(double: (high as NSString).doubleValue)
                        }
                    }
                    if let foil = foil {
                        if foil != "0" {
                            dict[TCGPlayerPricing.Keys.FoilPrice] = NSNumber(double: (foil as NSString).doubleValue)
                        }
                    }
                    if let link = link {
                        dict[TCGPlayerPricing.Keys.Link] = JJJUtil.trim(link)
                    }
                    dict[TCGPlayerPricing.Keys.FetchDate] = NSDate()
                    
                    let pricing = ObjectManager.sharedInstance.findOrCreateTCGPlayerPricing(card, dict: dict)
                    pricing.update(dict)
                    pricing.card = card
                    CoreDataManager.sharedInstance.savePrivateContext()
                }
                completion(cardID: cardID, error: nil)
            }
            
            let failure = { (error: NSError?) -> Void in
                dict[TCGPlayerPricing.Keys.FetchDate] = NSDate()
                
                let pricing = ObjectManager.sharedInstance.findOrCreateTCGPlayerPricing(card, dict: dict)
                pricing.update(dict)
                pricing.card = card
                CoreDataManager.sharedInstance.savePrivateContext()
                completion(cardID: cardID, error: error)
            }
            
            NetworkManager.sharedInstance.exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: false, success: success, failure: failure)
        
        } else {
            completion(cardID: cardID, error: nil)
        }
    }
    
    func needsToFetchTCGPlayerPricing(card: Card) -> Bool {
        if let pricing = card.pricing {
            if let fetchDate = pricing.fetchDate {
                let today = NSDate()
                let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                let components = gregorian!.components(.Hour, fromDate: fetchDate, toDate: today, options: NSCalendarOptions.MatchFirst)
                
                if components.hour >= TCGPlayerConstants.FetchDelay {
                    return true
                } else {
                    return false
                }
            }
        }
        
        return true
    }
}
