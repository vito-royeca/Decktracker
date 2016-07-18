//
//  BrowserTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 17/07/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit

class BrowserTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!

    // MARK: Actions
    
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        updateButtons()
        refreshButton.enabled = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom methods
    func displayPage(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    func updateButtons() {
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
        refreshButton.enabled = true
    }
}
