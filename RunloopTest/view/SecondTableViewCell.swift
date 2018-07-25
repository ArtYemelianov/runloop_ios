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
    
    func configure(_ model: FeedEntry){
        title.text = model.title
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        subtitle.text = model.subtitle
        date.text = model.date
    }
}

