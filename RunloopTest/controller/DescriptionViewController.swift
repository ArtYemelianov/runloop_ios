//
//  DescriptionViewController.swift
//  RunloopTest
//
//  Created by artus on 26.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit

class DescriptionViewController: UIViewController {
    static let description_identifier = "show_description"
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var feed: FeedEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        descriptionLabel.text = feed?.subtitle
    }
}
