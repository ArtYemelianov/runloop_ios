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
    
    init() {
        timer = TimerFacade()
        provider = DataProvider()
        setup()
    }
    
    /**
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
     Makes a fetching for all urls
    */
    private func makeFetchNow(){
        func composeCallback(url :String) -> (([FeedEntry]) -> Void) {
            return { array in
                self.map[url] = array
                self.delegate?.onUpdated(for: url)
            }
        }
        provider.retrieveData(strUrl: URL_BUSSINESS_NEWS, callback: composeCallback(url: URL_BUSSINESS_NEWS))
        provider.retrieveData(strUrl: URL_ENVIRONMENT, callback: composeCallback(url: URL_ENVIRONMENT))
        provider.retrieveData(strUrl: URL_ENTERTAIMENT, callback: composeCallback(url: URL_ENTERTAIMENT))
    }
}

extension SecondModel: RxRepeatingTimerDelegate{
    
    func onNext(id : String) {
        //TODO get request to server asynchroniously
        let disposable = provider.createRxFeedEntry(for: id)
            .take(1)
            .timeout(10, scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { array in
                    print("Done for next and retrieving feeds")
                    // it is safety operation because the map alters and is read only in main thread
                    self.map[id] = array
            }, onError: { error in
                print("Error happens \(error)")
            })
        disposable.dispose()
        
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.onUpdated(for: id)
        }
    }
}
