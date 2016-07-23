//
//  BrowserViewController.swift
//  Decktracker
//
//  Created by Jovit Royeca on 22/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import MBProgressHUD

class BrowserViewController: UIViewController {

    // MARK: Variables
    var toolBarHidden = false
    var navigationTitle: String?
    var html:String?
    var urlString:String?
    
    // MARK: Outlets
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: Outlets
    @IBAction func backAction(sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @IBAction func forwardAction(sender: UIBarButtonItem) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateButtons()
        refreshButton.enabled = false
        
        toolBar.hidden = toolBarHidden
        navigationItem.title = navigationTitle
        if let html = html {
            webView.loadHTMLString(html, baseURL: NSURL(fileURLWithPath: "\(NSBundle.mainBundle().bundlePath)/web"))
            
        } else if let _ = urlString {
            displayPage()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Custom methods
    func displayPage() {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                let request = NSURLRequest(URL: url)
                webView.loadRequest(request)
            }
        }
    }
    
    func updateButtons() {
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
        refreshButton.enabled = true
    }
    
    func displayCard(cardName: String) {
        let predicate = NSPredicate(format: "name == %@", cardName)
        let sorters = [NSSortDescriptor(key: "set.releaseDate", ascending: true)]
        
        if let card = ObjectManager.sharedInstance.findObjects("Card", predicate: predicate, sorters: sorters).first as? Card,
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CardDetailsViewController") as? CardDetailsViewController,
            let navigationController = navigationController {
                
                controller.cardOID = card.objectID
                navigationController.pushViewController(controller, animated: true)
        }
    }
}

// MARK: UIWebViewDelegate
extension BrowserViewController : UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let url = request.URL {
            let requestString = url.absoluteString
            
            if requestString.hasPrefix("http://www.magiccards.info/query") {
                let urlComponents = NSURLComponents(string: requestString)
                let queryItems = urlComponents?.queryItems
                let q = queryItems?.filter({$0.name == "q"}).first
                if let value = q?.value {
                    let r = value.startIndex.advancedBy(1)
                    let cardName = value.substringFromIndex(r).stringByReplacingOccurrencesOfString("+", withString: " ")
                    displayCard(cardName)
                }
                
                return false
            }
            
            return true
        }
        
        return false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        MBProgressHUD.showHUDAddedTo(webView, animated: true)
        updateButtons()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideHUDForView(webView, animated: true)
        updateButtons()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        MBProgressHUD.hideHUDForView(webView, animated: true)
        
        if let error = error {
            if let message = error.userInfo[NSLocalizedDescriptionKey] {
                let html = "<html><center>\(message)</center></html>"
                webView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
}
