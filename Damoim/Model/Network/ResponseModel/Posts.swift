//
//  Posts.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct Posts: Decodable {
    let data: [Post]
    let next_cursor: String
}

struct Post: Decodable {
    let post_id: String
    let product_id: String
    let title: String
    let price: Int?
    let content: String
    let content1: String // 장소
    let content2: String // 일정
    let content3: String // 최대인원
    let content4: String // 위치 좌표로 변경
    let content5: String // 카테고리
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes: [String]
    let likes2: [String]
    let hashTags: [String]
    let comments: [Comment]
    
    var postItem: PostItem {
        return PostItem(post_id: post_id, product_id: product_id, title: title, content: content, content1: content1, content2: content2, content3: content3, content4: content4, content5: content5, createdAt: createdAt, creator: creator, files: files, likes: likes, likes2: likes2, hashTags: hashTags, comments: comments)
    }
    
    var descriptionLabel: String {
        let components = content1.split(separator: " ")

        let district = components[1]
        
        return "\(district) · \(content2)"
    }
    
    var headCountLabel: String {
        return "\(l10nKey.labelHeadCount.rawValue.localized) \(likes.count)/\(content3)"
    }
}

struct Creator: Codable, Hashable {
    let user_id: String
    let nick: String
    let profileImage: String?
}

struct Comment: Codable, Hashable {
    let comment_id: String
    let content: String
    let createdAt: String
    let creator: Creator
    
    var timeAgo: String {
        return RelativeDateManager.shared.toAgo(createdAt: createdAt)
    }
}
