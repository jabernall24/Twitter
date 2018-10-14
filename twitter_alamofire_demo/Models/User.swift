//
//  User.swift
//  twitter_alamofire_demo
//
//  Created by Jesus Andres Bernal Lopez on 10/3/18.
//  Copyright © 2018 Charles Hieger. All rights reserved.
//

import UIKit

class User {
    var name: String?
    var screenName: String?
    var profile_image_url_https: String?
    var dictionary: [String: Any]?
    var followersCount: Int?
    var followingCount: Int?
    var createdAt: String?
    var tweetCount: Int?

    private static var _current: User?
    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        
        profile_image_url_https = dictionary["profile_image_url_https"] as? String
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        createdAt = dictionary["created_at"] as? String
        tweetCount = dictionary["statuses_count"] as? Int

    }
    
    static var current: User? {
        get {
            if _current == nil {
                let defaults = UserDefaults.standard
                if let userData = defaults.data(forKey: "currentUserData") {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! [String: Any]
                    _current = User(dictionary: dictionary)
                }
            }
            return _current
        }
        set (user) {
            _current = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.removeObject(forKey: "currentUserData")
            }
        }
    }

}
