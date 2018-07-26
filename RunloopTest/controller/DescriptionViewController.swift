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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        descriptionLabel.text = feed?.subtitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
