//
//  categoriesViewController.swift
//  tradeMeTask
//
//  Created by Refik Fatih Ustok on 11/09/16.
//  Copyright © 2016 Refik Fatih Ustok. All rights reserved.
//

import UIKit

class categoriesViewController: ViewController, UITableViewDataSource, UITableViewDelegate {

    /* I parse and show the categories in this view controller */

    @IBOutlet var categoryView: UIView!
    @IBOutlet weak var categories: UITableView!
    
    var categoryInitial = Category()
    var selectedCategoryFinal = Category()
    var Categories = [Category]()
    var status = Int()
    var tradeMeDicti = NSDictionary()
    var checkSubcategory = Int()
    
    var onDataAvailable : ((data: Category) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        checkSubcategory = 1
        getCategories()
        categories.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
 

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let result = Categories[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("category") as! categoryTableViewCell
        cell.titleLabel.text =   result.name
        if Categories[indexPath.row].subcategory != nil {
            cell.subcategoryPhoto.image = UIImage(named: "arrow")
        }
        else{
            cell.subcategoryPhoto.image = UIImage()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedRow = Categories[indexPath.row].subcategory
        selectedCategoryFinal = Categories[indexPath.row]
        self.onDataAvailable?(data: selectedCategoryFinal)
        if selectedRow != nil {
        checkSubcategory = 1
        dispatch_async(dispatch_get_main_queue()) {
                   self.Categories = [Category]()
           
                  for subcategoryc in selectedRow!{
                    let SelName = subcategoryc["Name"] as? String
                    if SelName != nil{
                        self.categoryInitial.name = SelName!
                    }
                    let SelNumber = subcategoryc["Number"] as? String
                    if SelNumber != nil {
                        self.categoryInitial.number = SelNumber!
                    }
                    let SelSubcategory = subcategoryc["Subcategories"] as? NSArray
                    if SelSubcategory != nil {
                       self.categoryInitial.subcategory = SelSubcategory!
                    }

                    self.Categories.append(self.categoryInitial)
                    self.categoryInitial = Category()
            }
            
                  self.categories.reloadData()
            }

        }
        else{
            checkSubcategory = 0
            self.selectedCategoryFinal = self.Categories[indexPath.row]
            self.onDataAvailable?(data: selectedCategoryFinal)
            dismiss()
        }
    }


    /* Get the categories using trademe API. as there is no need number, searchstring and lisingid, these values are nil */
    func getCategories(){
        trademeSearchAPI().getSearchData("Category", number: nil, searchString: nil, listingId: nil) { (trademeDic, statusN) -> () in
            
            self.status = statusN
            self.tradeMeDicti = trademeDic
          
            if(self.status==200){
                dispatch_async(dispatch_get_main_queue()) {
                    print("successful")
                    let categories = self.tradeMeDicti["Subcategories"] as! NSArray
                   
                    for category in categories{
                        let nameC = category["Name"] as? String
                        if nameC != nil {
                            self.categoryInitial.name = nameC!
                        }
                        
                        let numberC = category["Number"] as? String
                        if numberC != nil{
                            self.categoryInitial.number = numberC!
                        }
                        
                        let subcategoryC = category["Subcategories"] as? NSArray
                        if subcategoryC != nil {
                            self.categoryInitial.subcategory = subcategoryC!

                            }
                        self.Categories.append(self.categoryInitial)

                    }
                    self.categories.reloadData()
                }
            }
            else {
                print("unsuccesful")
            }
        }
        
    }

    @IBAction func doneTapped(sender: UIButton) {
        self.onDataAvailable?(data: selectedCategoryFinal)
        dismiss()
    }
  
}
