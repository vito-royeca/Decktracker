//
//  TCGPlayerPricing.swift
//  DataSource
//
//  Created by Jovit Royeca on 14/07/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

@objc(TCGPlayerPricing)
class TCGPlayerPricing: NSManagedObject {

    struct Keys {
        static let FetchDate = "fetchDate"
        static let FoilPrice = "foilavgprice"
        static let HighPrice = "hiprice"
        static let Link = "link"
        static let LowPrice = "lowprice"
        static let MidPrice = "avgprice"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("TCGPlayerPricing", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        fetchDate = dictionary[Keys.FetchDate] as? NSDate
        foilPrice = dictionary[Keys.FoilPrice] as? NSNumber
        highPrice = dictionary[Keys.HighPrice] as? NSNumber
        link = dictionary[Keys.Link] as? String
        lowPrice = dictionary[Keys.LowPrice] as? NSNumber
        midPrice = dictionary[Keys.MidPrice] as? NSNumber
    }

}
