//
//  searchTableViewCell.swift
//  tradeMeTask
//
//  Created by Refik Fatih Ustok on 11/09/16.
//  Copyright © 2016 Refik Fatih Ustok. All rights reserved.
//

import UIKit

class searchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listingLabel: UILabel!
    
    
    @IBOutlet weak var listingThumb: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.text = "Unknown title"
        listingLabel?.text = "Unknown listing"
        }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
}
