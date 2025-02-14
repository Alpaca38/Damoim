//
//  Profile.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct Profile: Decodable {
    let user_id: String
    let email: String?
    let nick: String
    let phoneNum: String?
    let birthDay: String?
    let profileImage: String?
    let followers: [Creator]
    let following: [Creator]
    let posts: [String]
    
    var followerCount: String {
        return String(followers.count)
    }
    
    var followingCount: String {
        return String(following.count)
    }
    
    var feedCount: String {
        return String(posts.count)
    }
}
