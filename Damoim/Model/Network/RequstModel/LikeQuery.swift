//
//  LikeQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct LikeQuery: Encodable {
    let postId: String
    let like_status: Bool
}
