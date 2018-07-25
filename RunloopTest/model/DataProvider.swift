//
//  DataProvider.swift
//  RunloopTest
//
//  Created by artus on 25.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import RxSwift

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
     Retrieves data asynchronously from server by specifc url
     - Parameter strUrl: Specific url
     - Parameter callback: Result of retrieving
     */
    func retrieveData(strUrl: String, callback: @escaping ([FeedEntry])->Void ) {
        
        var newScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "backgroundJob")
        Observable<[FeedEntry]>.create( { observer -> Disposable in
            print("retrieve Data done \(Thread.current.name)")
            Thread.sleep(forTimeInterval: 1)
            guard let url = strUrl.toURL else {
                observer.onNext(Array())
                observer.onCompleted()
                return Disposables.create()
            }
            let array = self.loadData(for: url)
            observer.onNext(array)
            observer.onCompleted()
            return Disposables.create()
        })
            
            .subscribeOn(newScheduler)
            .observeOn(MainScheduler.instance)
            .timeout(5.0, scheduler: scheduler)
            .subscribe(onNext: { [unowned self] array in
                print("onNext done \(Thread.current.name)")
                callback(array)
                }, onError: {error in
                    print("onError  \(Thread.current.name)")
            }, onCompleted: {
                print("onCompleted \(Thread.current.name)")
            }).disposed(by: self.disposeBag)
    }
    
}

extension String {
    var toURL: URL? {
        return URL(string: self)
    }
}
