//
//  TimelineViewController.swift
//  twitter_alamofire_demo
//
//  Created by Aristotle on 2018-08-11.
//  Copyright © 2018 Charles Hieger. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, UIScrollViewDelegate {
    
    func did(post: Tweet) {
        self.getTweets()
    }
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var tweets: [Tweet] = []
    var refresh = UIRefreshControl()
    var max_id: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        didPullToRefresh(refresh)
        tableView.insertSubview(refresh, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.title = "Home"
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
        
        if(indexPath.row == self.tweets.count - 1){
            moreTweets()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getTweets(){
        activityIndicator.startAnimating()
        APIManager.shared.getHomeTimeLine( completion: { (tweet: [Tweet]?,error: Error?) in
            if let tweet = tweet{
                self.tweets = tweet
                self.max_id = tweet[tweet.count - 1].id
                self.tableView.reloadData()
                self.refresh.endRefreshing()
                self.activityIndicator.stopAnimating()
            }else{
                print("error: ", error?.localizedDescription ?? "Unknown" )
            }

        })
    }
    
    func moreTweets(){
        APIManager.shared.getHomeTimeLine(max_id: max_id) { (tweet: [Tweet]?,error: Error?) in
            if let tweet = tweet{
                self.tweets.append(contentsOf: tweet)
                self.max_id = tweet[tweet.count - 1].id
                self.tableView.reloadData()
                self.refresh.endRefreshing()
                self.activityIndicator.stopAnimating()
            }else{
                print("error: ", error?.localizedDescription ?? "Unknown" )
            }
        }
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        getTweets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tweetDetailViewController = segue.destination as? TweetDetailViewController{
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                let tweet = tweets[indexPath.row]
                tweetDetailViewController.tweet = tweet
            }
        }
        
        if let composeViewController = segue.destination as? ComposeViewController{
            composeViewController.delegate = self
        }
        
    }
    
    private func calculateIndexPathsToReload(from newTweets: [Tweet]) -> [IndexPath] {
        let startIndex = tweets.count - newTweets.count
        let endIndex = startIndex + newTweets.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
}
