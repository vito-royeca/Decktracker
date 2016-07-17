//
//  ThumbnailTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 11/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData

protocol ThumbnailDelegate : NSObjectProtocol {
    func seeAllAction(tag: Int)
    func didSelectItem(tag: Int, objectID: NSManagedObjectID, path: NSIndexPath)
}


class ThumbnailTableViewCell: UITableViewCell {

    // MARK: Constants
    static let CellHeight = CGFloat(128)
    
    // MARK: Variables
    weak var delegate: ThumbnailDelegate?
    private var _fetchRequest:NSFetchRequest? = nil
    var fetchRequest:NSFetchRequest? {
        get {
            return _fetchRequest
        }
        set (aNewValue) {
            
            if (_fetchRequest != aNewValue) {
                _fetchRequest = aNewValue
                
                // force reset the fetchedResultsController
                if let _fetchRequest = _fetchRequest {
                    let context = CoreDataManager.sharedInstance.mainObjectContext
                    fetchedResultsController = NSFetchedResultsController(fetchRequest: _fetchRequest,
                                                                          managedObjectContext: context,
                                                                          sectionNameKeyPath: nil,
                                                                          cacheName: nil)
                }
            }
        }
    }
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let context = CoreDataManager.sharedInstance.mainObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest!,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
    private var shouldReloadCollectionView = false
    private var blockOperation:NSBlockOperation?
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    // MARK: Actions
    @IBAction func seeAllAction(sender: UIButton) {
        if let delegate = delegate {
            delegate.seeAllAction(self.tag)
        }
    }
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let space = CGFloat(5.0)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(80, 100)
        
        collectionView.registerNib(UINib(nibName: "SetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Set")
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    // MARK: Custom methods
    func loadData() {
        if (fetchRequest) != nil {
            do {
                try fetchedResultsController.performFetch()
            } catch {}
            fetchedResultsController.delegate = self
        }
        
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension ThumbnailTableViewCell: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (fetchRequest) != nil,
            let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            let items = sectionInfo.numberOfObjects
            return items
            
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Set", forIndexPath: indexPath) as! SetCollectionViewCell
        
        if let set = fetchedResultsController.objectAtIndexPath(indexPath) as? Set {
            cell.setOID = set.objectID
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension ThumbnailTableViewCell: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate,
            let object = fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject {
            
            delegate.didSelectItem(self.tag, objectID: object.objectID, path: indexPath)
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension ThumbnailTableViewCell : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        shouldReloadCollectionView = false
        blockOperation = NSBlockOperation()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            blockOperation!.addExecutionBlock({
                self.collectionView.insertSections(NSIndexSet(index: sectionIndex))
            })
            
        case .Delete:
            blockOperation!.addExecutionBlock({
                self.collectionView.deleteSections(NSIndexSet(index: sectionIndex))
            })
            
        case .Update:
            blockOperation!.addExecutionBlock({
                self.collectionView.reloadSections(NSIndexSet(index: sectionIndex))
            })
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            blockOperation!.addExecutionBlock({
                self.collectionView.insertItemsAtIndexPaths([newIndexPath!])
            })
            
        case .Delete:
            blockOperation!.addExecutionBlock({
                self.collectionView.deleteItemsAtIndexPaths([indexPath!])
            })
            
        case .Update:
            if let indexPath = indexPath {
//                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                
//                    if let c = cell as? WeatherThumbnailCollectionViewCell,
//                        let weather = fetchedResultsController.objectAtIndexPath(indexPath) as? Weather {
//                        
//                        blockOperation!.addExecutionBlock({
//                            self.configureCell(c, weather: weather)
//                        })
//                    }
//                }
            }
            
        case .Move:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if shouldReloadCollectionView {
            collectionView.reloadData()
        } else {
            collectionView.performBatchUpdates({
                if let blockOperation = self.blockOperation {
                    blockOperation.start()
                }
            }, completion:nil)
        }
    }
}