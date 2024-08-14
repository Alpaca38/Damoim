//
//  HashTagSearchQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct HashTagSearchQuery: Encodable { // 해쉬태그가 포함된 포스트
    let next: String?
    let limit: String?
    let product_id: String?
    let hashTag: String? // 키워드
}
