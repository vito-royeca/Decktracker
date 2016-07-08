//
//  Ruling.swift
//  DataSource
//
//  Created by Jovit Royeca on 29/06/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Ruling: NSManagedObject {

    struct Keys {
        static let Text = "text"
        static let Date = "date"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Ruling", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        text = dictionary[Keys.Text] as? String
        
        if let d = dictionary[Keys.Date] as? String {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            date = formatter.dateFromString(d)
        }
    }

}
