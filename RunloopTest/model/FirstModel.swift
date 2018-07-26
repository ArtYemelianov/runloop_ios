//
//  FirstModel.swift
//  RunloopTest
//
//  Created by artus on 26.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit

@objc protocol FirstModelDelegate {
    /**
     Event about next tick
     */
    func onNextTick()
}

class FirstModel {

    private lazy var timer: RxRepeatingTimer = RxRepeatingTimer(id: "date_timer", timeinterval: 1)

    weak var delegate: FirstModelDelegate?
    var feed: FeedEntry?
    
    
    private static var Instance: FirstModel = {
        let model = FirstModel()
        return model
    }()
    
    class func shared() -> FirstModel {
        return Instance
    }
    
    private init() {
        timer.delegate = self
    }
    
    /**
     Formatted data
    */
    var formattedData: String {
        return currentTime
    }
    
    var name: String {
        return "Artem Yemelianov"
    }
    
    var titleFeed: String? {
        return feed?.title ?? nil
    }
    
    func willAppear(){
        timer.start()
    }
    
    func willDisappear(){
        timer.stop()
    }
    
}

extension FirstModel: RxRepeatingTimerDelegate {
    func onNext(id: String) {
        DispatchQueue.main.async {
            self.delegate?.onNextTick()
        }
    }
}

extension FirstModel{
    fileprivate var currentTime : String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }

}
