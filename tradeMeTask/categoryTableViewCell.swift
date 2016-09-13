//
//  categoryTableViewCell.swift
//  tradeMeTask
//
//  Created by Refik Fatih Ustok on 11/09/16.
//  Copyright © 2016 Refik Fatih Ustok. All rights reserved.
//

import UIKit

class categoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subcategoryPhoto: UIImageView!
       override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.text = "Unknown title"
        subcategoryPhoto?.image = UIImage()
        }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
