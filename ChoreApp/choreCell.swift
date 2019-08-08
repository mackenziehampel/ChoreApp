//
//  ChoreCell.swift
//  ChoreApp
//
//  Created by Mackenzie Hampel on 7/27/19.
//  Copyright © 2019 Mackenzie Hampel. All rights reserved.
//

import UIKit


class ChoreCell: UITableViewCell {
    @IBOutlet weak var choreDescription: UILabel!
    @IBOutlet weak var choreTitle: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
