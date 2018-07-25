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
     * Loads feeds from server
     * - Parameter url: The url
     * - Returns: Array of FeedEntries or empty list
     */
    private func loadData(for url: URL) -> [FeedEntry] {
        let parser : XmlParserManager = XmlParserManager().initWithURL(url) as! XmlParserManager
        let array = parser.feeds.map{ item -> FeedEntry in
            let obj = item as AnyObject
            let model = FeedEntry()
            model.title = obj.object(forKey: "title") as? String
            model.subtitle = obj.object(forKey: "description") as? String
            model.date = obj.object(forKey: "pubDate") as? String
            return model
        }
        return array
        
    }
    
    /**
     Creates observable for request
     - Parameter strUrl: Specific url
     - Returns: Composed observable object
    */
    private func createObservableForRequest(for strUrl: String) -> Observable<[FeedEntry]> {
        let newScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "backgroundJob")
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
            .take(1)
            .timeout(10, scheduler: scheduler)
            .subscribeOn(newScheduler)
            .observeOn(MainScheduler.instance)
        return observable
    }
    
    /**
     Retrieves data asynchronously from server by specifc url
     - Parameter strUrl: Specific url
     - Parameter callback: Result of retrieving
     */
    func retrieveData(strUrl: String, callback: @escaping ([FeedEntry])->Void ) {
        createObservableForRequest(for: strUrl)
        .subscribe(
            onNext: { [unowned self] array in
                callback(array)
            }, onError: {error in
                print("onError")
        }, onCompleted: {
            //do nothing
            print("onCompleted")
        }).disposed(by: self.disposeBag)
    }
    
    /**
     Retrieves data asynchronously from server by specifc url
     - Parameter firstStrUrl: Specific url for first
     - Parameter secondStrUrl: Specific url for second
     - Parameter callback: Result of retrieving
     */
    func retrieveData(firstStrUrl: String, secondStrUrl: String, callback: @escaping ([FeedEntry])->Void ) {
        let newScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "backgroundJob")
        let first = createObservableForRequest(for: firstStrUrl)
        let second = createObservableForRequest(for: secondStrUrl)
        let observable = Observable<[FeedEntry]>.zip(first, second, resultSelector: {
            (firstResult, secondResult) throws -> [FeedEntry] in
            return firstResult + secondResult
        })
        let disposable =  observable.take(1)
            .timeout(10, scheduler: scheduler)
            .subscribeOn(newScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [unowned self] array in
                    callback(array)
                }, onError: {error in
                    print("onError")
            }, onCompleted: {
                //do nothing
                print("onCompleted")
            })
        disposable.disposed(by: self.disposeBag)
    }
    
}

extension String {
    var toURL: URL? {
        return URL(string: self)
    }
}
