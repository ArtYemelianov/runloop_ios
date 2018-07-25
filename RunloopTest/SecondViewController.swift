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
        tableView.backgroundColor = UIColorFromRGB(rgbValue: 0x00B6ED)
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
        // XmlParserManager instance/object/variable
        let parser : XmlParserManager = XmlParserManager().initWithURL(data) as! XmlParserManager
        // Put feed in array
        feeds = parser.feeds as NSArray as! Array
        tableView.reloadData()
    }

    @IBAction func refleshClicked(_ sender: UIBarButtonItem) {
        loadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension SecondViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: feedIdentifier, for: indexPath)
        let feed  = feeds[indexPath.row]
        if let item = cell as? SecondTableViewCell {
//            item.configure(with: device)
        }
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(white: 1, alpha: 0.1)
        } else {
            cell.backgroundColor = UIColor(white: 1, alpha: 0.2)
        }
        
        let cellImageLayer: CALayer?  = cell.imageView?.layer
        cellImageLayer!.cornerRadius = 35
        cellImageLayer!.masksToBounds = true
        //        cell.imageView?.image = image
        cell.textLabel?.text = (feeds[indexPath.row] as AnyObject).object(forKey: "title") as? String
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        cell.detailTextLabel?.text = (feeds[indexPath.row] as AnyObject).object(forKey: "pubDate") as? String
        cell.detailTextLabel?.textColor = UIColor.white
        
        return cell
    }
    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFeed = feeds[indexPath.row]
        // TODO setTitle in First screen
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
