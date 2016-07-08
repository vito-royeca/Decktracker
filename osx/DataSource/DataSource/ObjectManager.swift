//
//  ObjectManager.swift
//   WTHRM8
//
//  Created by Jovit Royeca on 18/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import APTimeZones
import CoreData
import CoreLocation

class ObjectManager: NSObject {

    // MARK: Constants
    static let BatchUpdateNotification = "BatchUpdateNotification"
    
    // MARK: Variables
    private var privateContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.privateContext
    }
    private var mainObjectContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.mainObjectContext
    }
    
    // Mark: Custom methods
    func findCurrentWeather(cityID: NSNumber) -> Weather? {
        let sorter = NSSortDescriptor(key: "displayTime", ascending: true)
        let predicate = NSPredicate(format: "city.cityID = %@ AND current = %@", cityID, NSNumber(bool: true))
        
        return ObjectManager.sharedInstance.findObjects("Weather", predicate: predicate, sorters: [sorter]).first as? Weather
    }
    
    func forecastFetchRequest(cityID: NSNumber, date: NSDate) -> NSFetchRequest {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
        components.timeZone = NSTimeZone(name: "UTC")
        components.hour = 0
        components.minute = 0
        components.second = 0
        let minDisplayTime = calendar.dateFromComponents(components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        let maxDisplayTime = calendar.dateFromComponents(components)
        
        let sorter = NSSortDescriptor(key: "displayTime", ascending: true)
        let predicate = NSPredicate(format: "city.cityID = %@ AND current = %@ AND (displayTime >= %@ AND displayTime <= %@)", cityID, NSNumber(bool: false), minDisplayTime!, maxDisplayTime!)
        
        let fetchRequest = NSFetchRequest(entityName: "Weather")
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.predicate = predicate

        return fetchRequest
    }
    
    func findOrCreateWeather(dict: [String: AnyObject], cityID: NSNumber) -> Weather {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Weather in
            return Weather(dictionary: dict, context: context)
        }
        
        var displayTime:NSDate?
        if let d = dict[Weather.Keys.DisplayTime] as? NSNumber {
            displayTime = NSDate(timeIntervalSince1970: d.doubleValue)
        }
        return findOrCreateObject(dict, entityName: "Weather", objectFinder: ["displayTime": displayTime!, "city.cityID": cityID], initializer: initializer) as! Weather
    }
    
    func findOrCreateWeatherCondition(dict: [String: AnyObject]) -> WeatherCondition {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> WeatherCondition in
            return WeatherCondition(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "WeatherCondition", objectFinder: ["weatherConditionID": dict[WeatherCondition.Keys.WeatherConditionID]!], initializer: initializer) as! WeatherCondition
    }
    
    func findOrCreateCity(dict: [String: AnyObject]) -> City {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> City in
            return City(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "City", objectFinder: ["cityID": dict[City.Keys.CityID]!], initializer: initializer) as! City
    }
    
    func findOrCreateCountry(dict: [String: AnyObject]) -> Country {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Country in
            return Country(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Country", objectFinder: ["countryCode" : dict[Country.Keys.CountryCode]!], initializer: initializer) as! Country
    }
    
    func findOrCreatePhoto(dict: [String: AnyObject]) -> Photo {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Photo in
            return Photo(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Photo", objectFinder: ["photoID": dict[Photo.Keys.PhotoID]!], initializer: initializer) as! Photo
    }
    
    // MARK: Core methods
    func findOrCreateObject(dict: [String: AnyObject], entityName: String, objectFinder: [String: AnyObject], initializer: (dict: [String: AnyObject], context: NSManagedObjectContext) -> AnyObject) -> AnyObject {
        var object:AnyObject?
        var predicate:NSPredicate?
        
        for (key,value) in objectFinder {
            if predicate != nil {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, NSPredicate(format: "%K == %@", key, value as! NSObject)])
            } else {
                predicate = NSPredicate(format: "%K == %@", key, value as! NSObject)
            }
        }
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        do {
            if let m = try privateContext.executeFetchRequest(fetchRequest).first {
                object = m
                
            } else {
                object = initializer(dict: dict, context: privateContext)
                CoreDataManager.sharedInstance.savePrivateContext()
            }
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return object!
    }

    func findObjects(entityName: String, predicate: NSPredicate?, sorters: [NSSortDescriptor]) -> [AnyObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sorters
        
        var objects:[AnyObject]?
        
        do {
            objects = try privateContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return objects!
    }
    
    func fetchObjects(fetchRequest: NSFetchRequest) -> [AnyObject] {
        var objects:[AnyObject]?
        
        do {
            objects = try privateContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return objects!
    }
    
    func deleteObjects(entityName: String, objectFinder: [String: AnyObject]) {
        var predicate:NSPredicate?
        for (key,value) in objectFinder {
            if predicate != nil {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, NSPredicate(format: "%K == %@", key, value as! NSObject)])
            } else {
                predicate = NSPredicate(format: "%K == %@", key, value as! NSObject)
            }
        }
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        do {
            if let m = try privateContext.executeFetchRequest(fetchRequest).first as? NSManagedObject {
                privateContext.deleteObject(m)
                CoreDataManager.sharedInstance.savePrivateContext()
                
            }
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
    }
    
    func batchUpdate(entityName: String, propertiesToUpdate: [String: AnyObject], predicate: NSPredicate) {
        // code adapted from: http://code.tutsplus.com/tutorials/core-data-and-swift-batch-updates--cms-25120
        // Initialize Batch Update Request
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
        
        // Configure Batch Update Request
        batchUpdateRequest.resultType = .UpdatedObjectIDsResultType
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
        batchUpdateRequest.predicate = predicate
        
        do {
            // Execute Batch Request
            let batchUpdateResult = try privateContext.executeRequest(batchUpdateRequest) as! NSBatchUpdateResult
            
            // Extract Object IDs
            let objectIDs = batchUpdateResult.result as! [NSManagedObjectID]
            
            for objectID in objectIDs {
                let managedObject = privateContext.objectWithID(objectID)
                privateContext.refreshObject(managedObject, mergeChanges: false)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(ObjectManager.BatchUpdateNotification, object: nil, userInfo: nil)
            
        } catch {}
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = ObjectManager()
}
