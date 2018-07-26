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
    private lazy var timer: RxRepeatingTimer = RxRepeatingTimer(id: "date_timer", timeinterval: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dateAndTime.text = self.currentTime
        timer.start()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension FirstViewController {
    fileprivate var currentTime : String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }
}

extension FirstViewController: RxRepeatingTimerDelegate {
    func onNext(id: String) {
        DispatchQueue.main.async {
            self.dateAndTime.text = self.currentTime
        }
    }
}
