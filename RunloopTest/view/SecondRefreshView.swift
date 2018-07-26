//
//  SecondRefreshView.swift
//  RunloopTest
//
//  Created by artus on 26.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit
import RxSwift

/**
 This class presents a wrapper mapping of refresh control to be shown for user
 
 There is a problem and the class solves it, the refresh control hasnt time to be shown  because the finishing already near therefore we increase time for showing.
 */
class SecondRefreshView {
    private lazy var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    private var tableView: UITableView!
    
    private var lastUpdating: Double = 0
    private var minIntervalForUpdating: Double = 2
    private var disposable: Disposable?
    
    func configure(tableView: UITableView){
        self.tableView = tableView
        self.tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(completed), for: .valueChanged)
    }
    
    @objc func completed(){
        refreshControl.endRefreshing()
    }
    
    /**
     Show refresh control
    */
    func show(){
        if !refreshControl.isRefreshing {
            updateOrShedule(callback: {
                self.refreshControl.beginRefreshing()
                let offsetPoint = CGPoint.init(x: 0, y: -self.refreshControl.frame.size.height)
                self.tableView.setContentOffset(offsetPoint, animated: true)
            })
        }
    }
    
    func disappear(){
        if refreshControl.isRefreshing {
            updateOrShedule(callback: {
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    private func updateOrShedule(callback: @escaping () -> Void ){
        disposable?.dispose()
        
        let now = Date().timeIntervalSince1970
        if now - lastUpdating > minIntervalForUpdating {
            callback()
            lastUpdating = now
        }else {
            let interval = now - lastUpdating
            disposable = Observable<Int>.timer(minIntervalForUpdating-interval, scheduler: MainScheduler.instance)
                .subscribe(onNext: { _ in
                    callback()
                    self.lastUpdating = Date().timeIntervalSince1970
                })
        }
    }
    
    deinit {
        disposable?.dispose()
    }
}
