//
//  SecondModel.swift
//  RunloopTest
//
//  Created by artus on 26.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit
import RxSwift

let URL_BUSSINESS_NEWS = "http://feeds.reuters.com/reuters/businessNews"
let URL_ENVIRONMENT = "http://feeds.reuters.com/reuters/environment"
let URL_ENTERTAIMENT = "http://feeds.reuters.com/reuters/entertainment"

/**
 Delegate of Model
 */
protocol SecondModelDelegate {
    func onUpdated(for: String)
    func onFetchingStarted()
    func onFetchingFinished()
}

/**
 Presents model for SecondViewController
 */
class SecondModel  {
    private let timer: TimerFacade
    private let timeinterval: TimeInterval = 5
    public var delegate: SecondModelDelegate?
    private let provider: DataProvider
    private var map =  [String: [FeedEntry]]()
    
    private var atomicMonitor = DispatchQueue(label: "atomic")
    private var counter: Int32 = 0
    var selectedFeed: FeedEntry? {
        didSet{
            FirstModel.shared().feed = selectedFeed
        }
    }
    
    init() {
        timer = TimerFacade()
        provider = DataProvider()
        setup()
    }
    
    /**
     Sets timers
    */
    private func setup(){
        func composeRxTimer(url : String) -> RxRepeatingTimer {
            let rxTimer = RxRepeatingTimer(id: url, timeinterval: 5)
            rxTimer.delegate = self
            return rxTimer
        }
        timer.timers.append(composeRxTimer(url: URL_BUSSINESS_NEWS))
        timer.timers.append(composeRxTimer(url: URL_ENVIRONMENT))
        timer.timers.append(composeRxTimer(url: URL_ENTERTAIMENT))
    }

    func willAppear(){
        timer.start()
        makeFetchNow()
    }
    
    func willDisappear(){
        timer.stop()
    }
    
    func retrieveNewestData(for array: [String]) -> [[FeedEntry]]{
        let arrayFeeds = array.map{ item -> [FeedEntry] in map[item] ?? Array<FeedEntry>() }
            .filter{ arr -> Bool in !arr.isEmpty }
        return arrayFeeds
    }
    
    /**
     Makes the fetching for all urls
    */
    private func makeFetchNow(){
        func composeCallback(url :String) -> (([FeedEntry]) -> Void) {
            return { array in
                self.map[url] = array
                self.delegate?.onUpdated(for: url)
                self.decreaseCounter()
            }
        }
        
        increaseCounter()
        provider.retrieveData(strUrl: URL_BUSSINESS_NEWS, callback: composeCallback(url: URL_BUSSINESS_NEWS))
        
        increaseCounter()
        provider.retrieveData(strUrl: URL_ENVIRONMENT, callback: composeCallback(url: URL_ENVIRONMENT))
        
        increaseCounter()
        provider.retrieveData(strUrl: URL_ENTERTAIMENT, callback: composeCallback(url: URL_ENTERTAIMENT))
    }
    
    /**
     Notify controller about fetching status changed.
     - Parameter status: If status is in fetching - true. Otherwise - false
     */
    fileprivate func notifyFetchingStatus(status: Bool) {
        if status{
            DispatchQueue.main.async {
                self.delegate?.onFetchingStarted()
            }
        }else {
            DispatchQueue.main.async {
                self.delegate?.onFetchingFinished()            }
        }
    }
}

extension SecondModel: RxRepeatingTimerDelegate{
    
    fileprivate func increaseCounter(){
        atomicMonitor.sync {
            counter += 1
            if counter == 1 {
                notifyFetchingStatus(status: true)
            }
        }
    }
    
    fileprivate func decreaseCounter(){
        atomicMonitor.sync {
            counter -= 1
            if counter == 0 {
                notifyFetchingStatus(status: false)
            }else if counter < 0 {
                fatalError("Counter is less than zero")
            }
        }
    }
    
    func onNext(id : String) {
        // makes request to server synchronously
        increaseCounter()
        
        let disposable = provider.createRxFeedEntry(for: id)
            .take(1)
            .timeout(10, scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { array in
                    // it is safety operation because the map alters and is read only in main thread
                    self.map[id] = array
            }, onError: { error in
                // TODO handle timeout is over
                print("Error Timeoout is over for \(id)")
            })
        disposable.dispose()
        
        decreaseCounter()
        
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.onUpdated(for: id)
        }
    }
}
