//
//  FollowQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/19/24.
//

import Foundation

struct FollowQuery: Encodable {
    let userId: String
}

struct UnFollowQuery: Encodable {
    let userId: String
}
