//
//  searchViewController.swift
//  tradeMeTask
//
//  Created by Refik Fatih Ustok on 11/09/16.
//  Copyright © 2016 Refik Fatih Ustok. All rights reserved.
//

import UIKit

class searchViewController: ViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    /* I show the search results in this view controller */
    var buttonTitle = "Please select a Category"
    var eachResult = Result()
    var allResults = [Result]()
    var status = Int()
    var tradeMeSearchDicti = NSDictionary()
    var searchWordTyped = String()
    var tapRecognizer: UITapGestureRecognizer? = nil
    var selCategory = Category()

    var imageCache = [String:UIImage]()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var selectedCategory: UILabel!

     @IBOutlet weak var resultsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* ProcessData is for processing the category and showing the results simultaneously  */
    func processData(data: Category) {
       
        if data.name != nil{
            selectedCategory.hidden = false
            selectedCategory.text = "Selected Category: \(data.name)"
            selCategory = data
            if self.connectedToNetwork() == true {
            SearchList(selCategory.number, searchWord: searchWordTyped)
            }
            else{
            self.showErrorAlert("No Internet Connection", defaultMessage: "Please check your internet connection for searching on TradeMe", errors: [])
            }
        }

    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let result = self.allResults[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("list") as! searchTableViewCell
        cell.titleLabel.text = result.name
        cell.listingLabel.text = "\(result.ListingId)"
        // Start by setting the cell's image to a static file
        // Without this, we will end up without an image view!
        cell.imageView?.image = UIImage(named: "trademe")
        if result.photo != nil{
        let photourl = NSURL(string: result.photo)
        
        // If this image is already cached, don't re-download
        if let img = imageCache[result.photo] {
            cell.imageView?.image = img
        }
        else {
            // The image isn't cached, download the img data
            // We should perform this in a background thread
            
            let request: NSURLRequest = NSURLRequest(URL: photourl!)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Store the image in to our cache
                    self.imageCache[result.photo] = image
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }})
                }
                else {
                    print("Error")
                }
            })
            task.resume()}
        }
        return cell

        }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
              _ = UIStoryboard (name: "Main", bundle: nil)
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("listingViewController") as! listingViewController
        detailController.listingSelected = allResults[indexPath.row]
        let modalViewController = detailController
        modalViewController.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(modalViewController, animated:true, completion: nil)
    }
    
    
    

    @IBAction func categoriesTapped(sender: AnyObject) {
        if self.connectedToNetwork() == true {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("categoriesViewController") as! categoriesViewController
        let modalViewController = detailController
        modalViewController.onDataAvailable = {[weak self]
                (data) in
                if let weakSelf = self {
                    weakSelf.processData(data)
                }
        }
        modalViewController.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(modalViewController, animated:true, completion: nil)
        }
        else{
           self.showErrorAlert("No Internet Connection", defaultMessage: "Please check your internet connection for searching on TradeMe", errors: [])  
        }

    }
    

    func SearchList(number: String, searchWord: String){
        allResults = [Result]()
        trademeSearchAPI().getSearchData( "Search", number: number, searchString: searchWord, listingId: nil) { (trademeSearchDic, statusN) -> () in              self.status = statusN
            self.tradeMeSearchDicti = trademeSearchDic

            if(self.status==200){
                 dispatch_async(dispatch_get_main_queue(), {
                    
                    let searchresults = self.tradeMeSearchDicti["List"] as! NSArray
                    for searchresult in searchresults{
                        let titleR = searchresult["Title"] as? String
                        if titleR != nil {
                            self.eachResult.name = titleR!
                        }
                        
                        let listingR = searchresult["ListingId"] as? Int
                        if listingR != nil{
                            self.eachResult.ListingId = listingR!
                        }
                        
                        let photoR = searchresult["PictureHref"] as? String
                        if photoR != nil{
                            self.eachResult.photo = photoR!
                        }

                        self.allResults.append(self.eachResult)
 
                    }
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.resultsTable.reloadData()})
                })
            }
            else{
                 self.showErrorAlert("Sorry!!!", defaultMessage: "We couldn't get the data!!!", errors: [])
            }
        }
    }
    
    
    
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    //Action to dismiss the keyboard when a tap was performed outside the text view
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchWordTyped = searchTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        unsubscribeFromKeyboardNotifications()
        var selnumber = selCategory.number
        
        if selnumber == nil {
            selnumber = ""
        }
        
         if self.connectedToNetwork() == true {
        SearchList(selnumber, searchWord: searchWordTyped)
        }
         else{
            self.showErrorAlert("No Internet Connection", defaultMessage: "Please check your internet connection for searching on TradeMe", errors: [])
   
        }
        
        resultsTable.reloadData()
        
        
        
        return true
    }

    //Keyboard Related Functions
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(searchViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(searchViewController.keyboardWillHide(_:))    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if(true ){ //print("Keyboard is shown") We can also move the screen here if needed, however in this app it is not needed.
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(false){ //print("Keyboard is hidden")
        }
    }

   

}

