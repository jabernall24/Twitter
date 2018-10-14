//
//  FollowersProfileViewController.swift
//  twitter_alamofire_demo
//
//  Created by Jesus Andres Bernal Lopez on 10/13/18.
//  Copyright © 2018 Charles Hieger. All rights reserved.
//

import UIKit

class FollowersProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var tweetsCount: UILabel!
    
    var tweet: Tweet!
    var tweets: [Tweet] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: (tweet.user?.profile_image_url_https!)!)
        let data = try! Data(contentsOf: url!)
        profileImageView.image = UIImage(data: data)
        
        authorLabel.text = tweet.user?.name
        screenNameLabel.text = "@\(String(describing: tweet.user!.screenName!))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        guard let date = dateFormatter.date(from: (User.current?.createdAt!)!) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let displayDate = formatter.string(from: date)
        
        joinedLabel.text = "Joined \(displayDate)"
        followersCountLabel.text = String(describing: tweet.user!.followersCount!)
        followingCountLabel.text = String(describing: tweet.user!.followingCount!)
        
        tweetsCount.text = "Tweets:\n\(tweet.user!.tweetCount!)"

    }
    
}
