//
//  PostItem.swift
//  Damoim
//
//  Created by 조규연 on 8/16/24.
//

import Foundation
import RxDataSources
import KakaoMapsSDK

struct PostItem: Codable, Hashable, IdentifiableType {
    var identity = UUID().uuidString
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
    
    var descriptionLabel: String {
        let components = content1.split(separator: " ")

        let district = components[1]
        
        return "\(district) · \(content2)"
    }
    
    var profileLabel: String {
        return "\(creator.nick) \(likes.count)명 참여"
    }
    
    var headCountLabel: String {
        return "\(l10nKey.labelHeadCount.rawValue.localized) \(likes.count)/\(content3)"
    }
    
    var coordinate: GeoCoordinate {
        let components = content4.split(separator: " ")
        let x = Double(components[0]) ?? 0
        let y = Double(components[1]) ?? 0
        
        let coord = GeoCoordinate(longitude: x / 10000000, latitude: y / 10000000)
        
        return coord
    }
}
