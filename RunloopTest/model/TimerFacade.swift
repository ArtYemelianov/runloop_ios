//
//  TimerFacade.swift
//  RunloopTest
//
//  Created by artus on 26.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit

/**
 Pattern Facede for specific set of timers
 */
class TimerFacade: RepeatingTimerProtocol {
    var timers : [RepeatingTimerProtocol] = Array()
    
    func start() {
        timers.forEach{ item in
            item.start()
        }
    }
    
    func stop() {
        timers.forEach{ item in
            item.stop()
        }
    }
    
}
