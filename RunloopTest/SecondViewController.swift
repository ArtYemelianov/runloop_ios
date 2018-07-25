//
//  SecondViewController.swift
//  RunloopTest
//
//  Created by artus on 25.07.2018.
//  Copyright © 2018 artus. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, XMLParserDelegate {
    private let URL_BUSSINESS_NEWS = "http://feeds.reuters.com/reuters/businessNews"
    private let URL_ENVIRONMENT = "http://feeds.reuters.com/reuters/environment"
    private let URL_ENTERTAIMENT = "http://feeds.reuters.com/reuters/entertainment"
    private let feedIdentifier = "feed_identifier"
    
    fileprivate var feeds: Array<Any> = Array()
    private var url: URL!
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        loadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        url = URL(string: URL_BUSSINESS_NEWS)!
        loadRss(url)
    }
    
    func loadRss(_ data: URL) {
        let parser : XmlParserManager = XmlParserManager().initWithURL(data) as! XmlParserManager
        feeds = parser.feeds as NSArray as! Array
        tableView.reloadData()
    }

    @IBAction func refleshClicked(_ sender: UIBarButtonItem) {
        loadData()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
        let model = SecondFeedModel()
        model.title = (feed as AnyObject).object(forKey: "title") as? String
        model.subtitle = (feed as AnyObject).object(forKey: "description") as? String
        model.date = (feed as AnyObject).object(forKey: "pubDate") as? String
        if let item = cell as? SecondTableViewCell {
            item.configure(model)
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
        let feed = feeds[indexPath.row]
        first.selectedFeed.text = (feed as AnyObject).object(forKey: "title") as? String
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
    
}
