//
//  listingViewController.swift
//  tradeMeTask
//
//  Created by Refik Fatih Ustok on 12/09/16.
//  Copyright © 2016 Refik Fatih Ustok. All rights reserved.
//

import UIKit

class listingViewController: ViewController {
    @IBOutlet weak var webView: UIWebView!
        var listingSelected: Result!
    
    
    /* I show the listing details here. Ideally, we can parse the data using trademeAPI. Due to the time constraint, I show the details of a listing on a webview. */

    override func viewDidLoad() {
        super.viewDidLoad()
        /* If the device is connected to the internet */
        if self.connectedToNetwork() == true {
        let listingid = listingSelected.ListingId!
        let requestURL = NSURL(string: "https://www.tmsandbox.co.nz/\(listingid)")
        let request = NSURLRequest(URL: (requestURL!))
        self.webView.loadRequest(request)  // load the website on webview 
        }
            /* If the device is not connected to the internet */

         else{
            self.showErrorAlert("No Internet Connection", defaultMessage: "Please check your internet connection for the details of the listing", errors: [])
 
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(listingViewController.dismiss))
        view.addGestureRecognizer(tap)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func pressedClose(sender: UIButton) {
        dismiss()
    }
}

