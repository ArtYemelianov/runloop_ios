//
//  FirstViewController.swift
//  RunloopTest
//
//  Created by artus on 25.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var selectedFeed: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    private lazy var model : FirstModel = {
        return FirstModel.shared()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    /**
     Sets MVC modules
    */
    private func setup(){
        model.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateAndTime.text = model.formattedData
        selectedFeed.text = model.titleFeed
        nameLabel.text = model.name
        model.willAppear()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        model.willDisappear()
    }
    
}

extension FirstViewController: FirstModelDelegate {
    func onNextTick() {
        self.dateAndTime.text = self.model.formattedData
    }
}
