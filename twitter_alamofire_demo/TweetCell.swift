//
//  TweetCell.swift
//  twitter_alamofire_demo
//
//  Created by Jesus Andres Bernal Lopez on 10/4/18.
//  Copyright © 2018 Charles Hieger. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import DateToolsSwift

class TweetCell: UITableViewCell, TTTAttributedLabelDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: TTTAttributedLabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    
    var tweet: Tweet!{
        didSet{
            let url = URL(string: tweet.user!.profile_image_url_https!)
            let data = try! Data(contentsOf: url!)
            if tweet.favorited == true{
                favoriteButton.setBackgroundImage(UIImage(named: "favor-icon-red"), for: .normal)
            }else{
                favoriteButton.setBackgroundImage(UIImage(named: "favor-icon"), for: .normal)
            }
            
            if tweet.retweeted == true{
                retweetButton.setBackgroundImage(UIImage(named: "retweet-icon-green"), for: .normal)
            }else{
                retweetButton.setBackgroundImage(UIImage(named: "retweet-icon"), for: .normal)
            }
            
            profileImageView.image = UIImage(data: data)
            authorLabel.text = tweet.user?.name
            tweetTextLabel.text = tweet.text
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            guard let date = dateFormatter.date(from: tweet.createdAtString!) else {
                fatalError("ERROR: Date conversion failed due to mismatched format.")
            }
            
            screenNameLabel.text = "@\(String(describing: tweet.user!.screenName!))"
            createdAtLabel.text = date.shortTimeAgoSinceNow
            favoriteCountLabel.text = String(describing: tweet.favoriteCount!)
            retweetCountLabel.text = String(describing: tweet.retweetCount!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        tweetTextLabel.delegate = self
        tweetTextLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        tweetTextLabel.preferredMaxLayoutWidth = tweetTextLabel.frame.size.width
        authorLabel.preferredMaxLayoutWidth = authorLabel.frame.size.width
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        print("touched on link")
        UIApplication.shared.open(url, options: [:])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tweetTextLabel.preferredMaxLayoutWidth = tweetTextLabel.frame.size.width
        authorLabel.preferredMaxLayoutWidth = authorLabel.frame.size.width
    }
    
    @IBAction func onRetweet(_ sender: Any) {
        if tweet.retweeted == true{
            tweet.retweeted = false
            tweet.retweetCount! -= 1
            retweetButton.setBackgroundImage(UIImage(named: "retweet-icon"), for: .normal)
            unRetweet()
            retweetCountLabel.text = String(describing: tweet.retweetCount!)
        }else{
            tweet.retweeted = true
            tweet.retweetCount! += 1
            retweetButton.setBackgroundImage(UIImage(named: "retweet-icon-green"), for: .normal)
            retweet()
            retweetCountLabel.text = String(describing: tweet.retweetCount!)
        }
    }
    
    @IBAction func onFavorite(_ sender: Any) {
        if tweet.favorited == true{
            tweet.favorited = false
            tweet.favoriteCount! -= 1
            favoriteButton.setBackgroundImage(UIImage(named: "favor-icon"), for: .normal)
            unFavorite()
            favoriteCountLabel.text = String(describing: tweet.favoriteCount!)
        }else{
            tweet.favorited = true
            tweet.favoriteCount! += 1
            favoriteButton.setBackgroundImage(UIImage(named: "favor-icon-red"), for: .normal)
            favorite()
            favoriteCountLabel.text = String(describing: tweet.favoriteCount!)
        }
    }
    
    func favorite(){
        APIManager.shared.favorite(tweet) { (tweet: Tweet?, error: Error?) in
            if let  error = error {
                print("Error favoriting tweet: \(error.localizedDescription)")
            } else if let tweet = tweet {
                print("Successfully favorited the following Tweet: \n\(tweet.text ?? "Tweet text is unknown") \(String(describing: error?.localizedDescription))")
            }
        }
    }
    func unFavorite(){
        APIManager.shared.unFavorite(tweet) { (tweet: Tweet?, error: Error?) in
            if let  error = error {
                print("Error un-Favoriting tweet: \(error.localizedDescription)")
            } else if let tweet = tweet {
                print("Successfully un-Favorited the following Tweet: \n\(tweet.text ?? "Tweet text is unknown") \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func retweet(){
        APIManager.shared.retweet(tweet) { (tweet: Tweet?, error: Error?) in
            if let  error = error {
                print("Error favoriting tweet: \(error.localizedDescription)")
            } else if let tweet = tweet {
                print("Successfully retweeted the following Tweet: \n\(tweet.text ?? "Tweet text is unknown") \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func unRetweet(){
        APIManager.shared.unRetweet(tweet) { (tweet: Tweet?, error: Error?) in
            if let  error = error {
                print("Error favoriting tweet: \(error.localizedDescription)")
            } else if let tweet = tweet {
                print("Successfully un retweeted the following Tweet: \n\(tweet.text ?? "Tweet text is unknown") \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
