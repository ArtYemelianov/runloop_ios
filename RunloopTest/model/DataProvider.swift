//
//  DataProvider.swift
//  RunloopTest
//
//  Created by artus on 25.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import RxSwift

/**
Presents data for controller. It is respondible for model in MVC patterns
TODO It is necessary to implement FeedCache which keeps stored date from server and more safety for reading from controller
 */
class DataProvider {
    private var scheduler: ConcurrentDispatchQueueScheduler!
    private let disposeBag = DisposeBag()
    
    init() {
        let timerQueue = DispatchQueue(label: "runloop.timer")
        scheduler = ConcurrentDispatchQueueScheduler(queue: timerQueue)
    }
    
    /**
     Loads feeds from server synchronously
     - Parameter url: The url
     - Returns: Array of FeedEntries or empty list
     */
    private func loadData(for url: URL) -> [FeedEntry] {
        let parser : XmlParserManager = XmlParserManager().initWithURL(url) as! XmlParserManager
        let array = parser.feeds.map{ item -> FeedEntry in
            let obj = item as AnyObject
            let model = FeedEntry()
            model.title = obj   .object(forKey: "title") as? String
            model.subtitle = obj.object(forKey: "description") as? String
            model.date = obj.object(forKey: "pubDate") as? String
            return model
        }
        return array
        
    }
    
    
    /**
     Creates observable to handle partifuclar url
     - Parameter strUrl: Specific url
     - Returns: Created observable object
    */
    func createRxFeedEntry(for strUrl: String) -> Observable<[FeedEntry]> {
        let observable = Observable<[FeedEntry]>.create( { observer -> Disposable in
            guard let url = strUrl.toURL else {
                observer.onNext(Array())
                observer.onCompleted()
                return Disposables.create(){
                    
                }
            }
            let array = self.loadData(for: url)
            observer.onNext(array)
            observer.onCompleted()
            return Disposables.create()
        })
        return observable
    }
    
    /**
     Composes observable with neccessary operators
     - Parameter strUrl: Specific url
     - Returns: Composed observable object
     */
    func composeObserveble(for strUrl: String) -> Observable<[FeedEntry]> {
        return createRxFeedEntry(for: strUrl)
                .take(1)
                .timeout(10, scheduler: scheduler)
    }
    
    /**
     Retrieves data asynchronously from server by specifc url
     - Parameter strUrl: Specific url
     - Parameter callback: Result of retrieving at Main thread
     */
    func retrieveData(strUrl: String, callback: @escaping ([FeedEntry])->Void ) {
        composeObserveble(for: strUrl)
            .subscribeOn(scheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { array in callback(array)
            }).disposed(by: self.disposeBag)
    }
    
    /**
     Retrieves data asynchronously from server by specifc url
     - Parameter firstStrUrl: Specific url for first
     - Parameter secondStrUrl: Specific url for second
     - Parameter callback: Result of retrieving at Main thread
     */
    func composeObserveble(firstStrUrl: String, secondStrUrl: String, callback: @escaping ([FeedEntry])->Void ) {
        let first = createRxFeedEntry(for: firstStrUrl)
            .subscribeOn(scheduler)
            .observeOn(MainScheduler.instance)
        let second = createRxFeedEntry(for: secondStrUrl)
            .subscribeOn(scheduler)
            .observeOn(MainScheduler.instance)
        let observable = Observable<[FeedEntry]>.zip(first, second, resultSelector: {
            (firstResult, secondResult) throws -> [FeedEntry] in
            return firstResult + secondResult
        })
        let disposable =  observable.take(1)
            .timeout(10, scheduler: scheduler)
            .subscribeOn(scheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { array in callback(array)
            })
        disposable.disposed(by: disposeBag)
    }
    
}

extension String {
    var toURL: URL? {
        return URL(string: self)
    }
}
