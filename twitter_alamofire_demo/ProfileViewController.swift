//
//  ProfileViewController.swift
//  twitter_alamofire_demo
//
//  Created by Jesus Andres Bernal Lopez on 10/13/18.
//  Copyright © 2018 Charles Hieger. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var usersImageView: UIImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usersScreenNameLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedContainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let numOfButtons: CGFloat = 1/2
    let tweetsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tweets", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(onUserTweets), for: .touchUpInside)
        return button
    }()
    let favoritesButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Favorites", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(onUserFavoriteTweets), for: .touchUpInside)
        return button
    }()
    let segmenetedLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        return view
    }()
    let tweetsLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
        return view
    }()
    let favoritesLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
        view.isHidden = true
        return view
    }()
    var tweets: [Tweet] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: User.current!.profile_image_url_https!)
        let data = try! Data(contentsOf: url!)
        usersImageView.image = UIImage(data: data)
        
        usersNameLabel.text = User.current?.name
        usersScreenNameLabel.text = "@\(String(describing: User.current!.screenName!))"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        guard let date = dateFormatter.date(from: (User.current?.createdAt!)!) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let displayDate = formatter.string(from: date)
        
        joinedLabel.text = "Joined \(displayDate)"
        followingCountLabel.text = "\(String(describing: User.current!.followingCount!))"
        followersCountLabel.text = "\(String(describing: User.current!.followersCount!))"
        

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        segmentedView()
        onUserTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.title = User.current?.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationItem.title = ""
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        if(tweetsButton.isUserInteractionEnabled == false){
            getUserTweets()
        }else{
            getUserFavorites()
        }
    }
    
    @objc func onUserTweets(){
        tweetsButton.setTitleColor(#colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1), for: .normal)
        tweetsButton.isUserInteractionEnabled = false
        tweetsLine.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
        tweetsLine.isHidden = false
        
        favoritesButton.setTitleColor(#colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), for: .normal)
        favoritesButton.isUserInteractionEnabled = true
        favoritesLine.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        favoritesLine.isHidden = true
        
        getUserTweets()
    }
    
    @objc func onUserFavoriteTweets(){
        tweetsButton.setTitleColor(#colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), for: .normal)
        tweetsButton.isUserInteractionEnabled = true
        tweetsLine.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        tweetsLine.isHidden = true
        
        favoritesButton.setTitleColor(#colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1), for: .normal)
        favoritesButton.isUserInteractionEnabled = false
        favoritesLine.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
        favoritesLine.isHidden = false
        
        getUserFavorites()
    }
    
    
    func segmentedView(){
        segmentedContainerView.addSubview(tweetsButton)
        tweetsButton.topAnchor.constraint(equalTo: segmentedContainerView.topAnchor).isActive = true
        tweetsButton.leadingAnchor.constraint(equalTo: segmentedContainerView.leadingAnchor).isActive = true
        tweetsButton.bottomAnchor.constraint(equalTo: segmentedContainerView.bottomAnchor).isActive = true
        tweetsButton.widthAnchor.constraint(equalTo: segmentedContainerView.widthAnchor, multiplier: numOfButtons).isActive = true
        
        segmentedContainerView.addSubview(favoritesButton)
        favoritesButton.topAnchor.constraint(equalTo: segmentedContainerView.topAnchor).isActive = true
        favoritesButton.leadingAnchor.constraint(equalTo: tweetsButton.trailingAnchor).isActive = true
        favoritesButton.bottomAnchor.constraint(equalTo: segmentedContainerView.bottomAnchor).isActive = true
        favoritesButton.widthAnchor.constraint(equalTo: segmentedContainerView.widthAnchor, multiplier: numOfButtons).isActive = true
        
        segmentedContainerView.addSubview(segmenetedLine)
        segmenetedLine.leadingAnchor.constraint(equalTo: segmentedContainerView.leadingAnchor).isActive = true
        segmenetedLine.trailingAnchor.constraint(equalTo: segmentedContainerView.trailingAnchor).isActive = true
        segmenetedLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        segmenetedLine.bottomAnchor.constraint(equalTo: segmentedContainerView.bottomAnchor).isActive = true
        
        segmentedContainerView.addSubview(tweetsLine)
        tweetsLine.leadingAnchor.constraint(equalTo: segmentedContainerView.leadingAnchor).isActive = true
        tweetsLine.widthAnchor.constraint(equalTo: segmentedContainerView.widthAnchor, multiplier: numOfButtons).isActive = true
        tweetsLine.bottomAnchor.constraint(equalTo: segmentedContainerView.bottomAnchor).isActive = true
        tweetsLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        segmentedContainerView.addSubview(favoritesLine)
        favoritesLine.leadingAnchor.constraint(equalTo: tweetsLine.trailingAnchor).isActive = true
        favoritesLine.widthAnchor.constraint(equalTo: segmentedContainerView.widthAnchor, multiplier: numOfButtons).isActive = true
        favoritesLine.bottomAnchor.constraint(equalTo: segmentedContainerView.bottomAnchor).isActive = true
        favoritesLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getUserTweets(){
        activityIndicator.startAnimating()
        APIManager.shared.getUserTimeLine { (tweet: [Tweet]?,error: Error?) in
            if let tweet = tweet{
                self.tweets = tweet
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }else{
                print("error: ", error?.localizedDescription ?? "Unknown" )
            }

        }
    }
    
    func getUserFavorites(){
        activityIndicator.startAnimating()
        APIManager.shared.getUserFavorites { (tweet: [Tweet]?,error: Error?) in
            if let tweet = tweet{
                self.tweets = tweet
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }else{
                print("error: ", error?.localizedDescription ?? "Unknown")
            }
        }
    }
    
    @IBAction func leftSwipe(_ sender: Any) {
        if(tweetsButton.isUserInteractionEnabled == false){
            onUserFavoriteTweets()
        }
    }
    
    @IBAction func rightSwipe(_ sender: Any) {
        if(favoritesButton.isUserInteractionEnabled == false){
            onUserTweets()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tweetDetailViewController = segue.destination as? TweetDetailViewController{
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                let tweet = tweets[indexPath.row]
                tweetDetailViewController.tweet = tweet
            }
        }
    }
    
}
