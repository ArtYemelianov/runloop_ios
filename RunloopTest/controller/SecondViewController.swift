//
//  SecondViewController.swift
//  RunloopTest
//
//  Created by artus on 25.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit
import RxSwift

enum Segment{
    case first
    case second
    
    /**
     First segment for index
     - Parameter index: Index of SegmentControl
    */
    static func segmentForIndex(index: Int) -> Segment?{
        return index == 0 ? .first : (index == 1 ? .second : nil)
    }
}

class SecondViewController: UIViewController, XMLParserDelegate {
    
    private let feedIdentifier = "feed_identifier"
    
    @IBOutlet weak var segmentedView: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var refresher: UIRefreshControl!
    
    private var feeds: [FeedEntry] = Array()
    
    fileprivate lazy var model: SecondModel = SecondModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        tableView.addSubview(refresher)
        refresher.tintColor = UIColorFromRGB(rgbValue: 0x0f0f0f )
        refresher.addTarget(self, action: #selector(completed), for: .valueChanged)

        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        model.delegate = self
    }
    
    @objc func completed(){
        // ends refleshing at once after swiping happened
        self.refresher!.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.willAppear()
        refresher.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Retrieves newest data
     */
    func retrieveData(for segment: Segment) -> [FeedEntry]{
        let arrayUrl = recognizeSegment(for: segment)
        let arrayFeeds = model.retrieveNewestData(for: arrayUrl)
        let result = arrayFeeds.flatMap{ $0}
        return result
    }
    
    func update() {
        feeds = retrieveData(for: Segment.segmentForIndex(index: segmentedView.selectedSegmentIndex)!)
        self.tableView.reloadData()
    }
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        // forbid retrieveing data HERE according condition of test task therefore we only retrieve store data
        update()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case DescriptionViewController.description_identifier:
            guard let cell = sender as? SecondTableViewCell,
                let indexPath = tableView.indexPath(for: cell)
                else {
                return
            }
            let controller  = segue.destination as! DescriptionViewController
            controller.feed = feeds[indexPath.row]
        default: break
            //do nothing
        }
    }
}

extension SecondViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: feedIdentifier, for: indexPath)
        
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColorFromRGB(rgbValue: 0xF0F0F0)
        } else {
            cell.backgroundColor = UIColor.clear
        }
        
        let feed  = feeds[indexPath.row]
        if let item = cell as? SecondTableViewCell {
            item.configure(feed)
        }
        return cell
    }
    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewControllers = appDelegate.window?.rootViewController?.childViewControllers
        let filtered: [UIViewController]  = viewControllers?.filter{ item in item is  FirstViewController } ?? Array()
        guard let controller =  filtered.first, let first = controller as? FirstViewController else {
            return
        }
        first.selectedFeed.text = feeds[indexPath.row].title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SecondViewController: SecondModelDelegate {
    func onFetchingStarted() {
        refresher.beginRefreshing()
    }
    
    func onFetchingFinished() {
        refresher.endRefreshing()
    }
    
    func onUpdated(for url: String) {
        guard let segment = recognizeURL(for: url),
            let current = segmentedView.currentSegment else {
                return
        }
        if segment != current || feeds.isEmpty {
            update()
        }
    }
}

extension SecondViewController {
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func recognizeURL(for strUrl: String) -> Segment? {
        if strUrl == URL_BUSSINESS_NEWS { return .first }
        else if strUrl == URL_ENVIRONMENT || strUrl == URL_ENTERTAIMENT { return .second }
        else { return nil }
    }
    
    func recognizeSegment(for segment: Segment) -> [String] {
        if segment == .first {
            return [URL_BUSSINESS_NEWS]
        }
        else if segment == .second {
            return [URL_ENTERTAIMENT , URL_ENVIRONMENT]
        }else {
            return Array()
        }
    }
    
}

extension UISegmentedControl {
    var currentSegment: Segment? {
        return Segment.segmentForIndex(index: selectedSegmentIndex)
    }
    
}

