//
//  RxRepeatingTimer.swift
//  RunloopTest
//
//  Created by artus on 26.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit
import RxSwift

/**
 Delegate for timer
 */
protocol RxRepeatingTimerDelegate{
    /**
     Triggers the timer done
     
     It is called from timer's thread therefore if you delay this thread
     a next timer scheduling will be shift
     
     - Parameter id: Particular id of timer
     */
    func onNext(id :String)
}

protocol RepeatingTimerProtocol {
    /**
     Starts a new timer
     */
    func start()
    
    /**
     Stops timer
     */
    func stop()
}

/**
 Presents repeating timer which works in rx principles
 */
class RxRepeatingTimer: RepeatingTimerProtocol{
    public var delegate: RxRepeatingTimerDelegate?
    
    public let scheduler : SerialDispatchQueueScheduler
    private var dispose: Disposable?
    
    fileprivate let timeinterval: TimeInterval
    fileprivate let id:String
    
    init(id: String, timeinterval: TimeInterval) {
        self.id = id
        self.timeinterval = timeinterval
        scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "rx_repeating_timer")
    }
    
    /**
     Starts a new timer, a previous will be canceled
     */
    func start(){
        stop()
        dispose = createRxTime.subscribe()
    }
    
    func stop(){
        dispose?.dispose()
        dispose = nil
    }
    
    deinit {
        stop()
    }
    
}

extension RxRepeatingTimer{
    /**
     Creates repeated rx timer
     */
    fileprivate var createRxTime: Observable<Int>
    {
        return Observable<Int>.timer(self.timeinterval, scheduler: scheduler)
            .observeOn(scheduler)
            .subscribeOn(scheduler)
            .flatMap({ i ->  Observable<Int> in
                self.delegate?.onNext(id : self.id)
                return self.createRxTime
            })
    }
}

