//
//  TextsViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 20/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils

class TextsViewController: UIViewController {

    // MARK: Variables
    var cardOID:NSManagedObjectID?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Card Texts"
        tableView.registerNib(UINib(nibName: "BrowserTableViewCell", bundle: nil), forCellReuseIdentifier: "browserCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Custom methods
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
extension TextsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("browserCell", forIndexPath: indexPath)
        
        if let c = cell as? BrowserTableViewCell {
            let card = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(cardOID!) as! Card
            
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
            
            c.toolBar.hidden = true
            c.webView.loadHTMLString(html!, baseURL: NSURL(fileURLWithPath: "\(NSBundle.mainBundle().bundlePath)/web"))
        }
        
        return cell
    }
}

// MARK: UITableVIewDelegate
extension TextsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.size.height
    }
}


