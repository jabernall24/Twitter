//
//  TimelineViewController.swift
//  twitter_alamofire_demo
//
//  Created by Aristotle on 2018-08-11.
//  Copyright © 2018 Charles Hieger. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet] = []
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTweets()
        
        refresh.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        didPullToRefresh(refresh)
        
        tableView.insertSubview(refresh, at: 0)
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        User.current = nil
        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
    func getTweets(){
        APIManager.shared.getHomeTimeLine { (tweet: [Tweet]?,error: Error?) in
            if let tweet = tweet{
                self.tweets = tweet
                self.tableView.reloadData()
                self.refresh.endRefreshing()
            }else{
                print("error: ", error?.localizedDescription ?? "Unknown" )
            }

        }
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        getTweets()
    }
}
