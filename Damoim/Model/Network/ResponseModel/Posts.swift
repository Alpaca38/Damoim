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
    let content: String
    let content1: String // 장소
    let content2: String // 일정
    let content3: String // 최대인원
    let content4: String // 비용
    let content5: String // 카테고리
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes: [String]
    let likes2: [String]
    let hashTags: [String]
    let comments: [Comment]
}

struct Creator: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String?
}

struct Comment: Decodable {
    let comment_id: String
    let content: String
    let createdAt: String
    let creator: [Creator]
}
