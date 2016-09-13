//
//  trademeSearchAPI.swift
//  tradeMeTask
//
//  Created by Refik Fatih Ustok on 11/09/16.
//  Copyright © 2016 Refik Fatih Ustok. All rights reserved.
//

import Foundation

class trademeSearchAPI {
    
    
    /*
     / This class is to parse data from trademe sandbox API. The app parses the category and search results data
     */
    
    /* API Credentials*/
    
    private let consumer_key = "A1AC63F0332A131A78FAC304D007E7D1"  //
    private let consumer_signature = "EC7F18B17A062962C6930A8AE88B16C7%26"
    
    /* */
    
    var address = String()
    
    
    func getSearchData(method: String, number: String?, searchString: String?, listingId: Int?, completion: (tradeMeSearchDic: NSDictionary, status: Int)->()) {
        /* we use this API in two different ways: Category and Search of which their base url addresses are different */
        if method == "Category"{
            address = "https://api.tmsandbox.co.nz/v1/Categories/0.json?"
        }
        else if method == "Search"{
             address =  "https://api.tmsandbox.co.nz/v1/Search/General.json?"
        }
        
        else{
            address = "https://api.tmsandbox.co.nz/v1/Listings/\(listingId!).json?"
            /* Unfortunately did not have much time to implement the listing */
        }
        
        address = address.stringByAppendingString("&oauth_consumer_key=" + consumer_key)
        address = address.stringByAppendingString("&oauth_signature_method=" + "PLAINTEXT")
        address = address.stringByAppendingString("&oauth_signature=" + consumer_signature)
        

        if number != nil && searchString != nil{
            address = address.stringByAppendingString("&category=" + number!)
            address = address.stringByAppendingString("&search_string=" + searchString!)
            address = address.stringByAppendingString("&rows=20")
            address = address.stringByAppendingString("&sort_order=FeaturedFirst")
        }

        
        let baseURL = NSURL(string: address)
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(baseURL!, completionHandler: { (tradeMeData: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            
            let httpResponse = response as? NSHTTPURLResponse
            let statusCode = httpResponse?.statusCode
            
            guard tradeMeData != nil else {
                print("Error: did not receive data")
                completion(tradeMeSearchDic: NSDictionary(),  status: 0)
                return
            }
            guard error == nil else {
                print("error calling the function")
                print(error)
                completion(tradeMeSearchDic: NSDictionary(),  status: 0)
                return
            }
            if (statusCode == 200) {
                let dataObject = NSData(contentsOfURL: tradeMeData!)
                let tradeMeDictionary: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataObject!, options: [])) as! NSDictionary

                completion(tradeMeSearchDic: tradeMeDictionary ,status: Int(statusCode!))

            }
                
                
            else {
                completion(tradeMeSearchDic: NSDictionary() ,status: 0)
            }
            
        })
        
        downloadTask.resume()
        
    }

    
}
