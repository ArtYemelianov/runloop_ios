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
    private var isAppeared = false
    private lazy var timer: RepeatingTimer = {
        return RepeatingTimer(timeInterval: 1)
    }()
    
    private var currentTime : String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer.eventHandler = {
            DispatchQueue.main.async {
                self.dateAndTime.text = self.currentTime
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dateAndTime.text = self.currentTime
        timer.resume()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.suspend()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
