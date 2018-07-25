//
//  SecondTableViewCell.swift
//  RunloopTest
//
//  Created by artus on 25.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit

class SecondTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
