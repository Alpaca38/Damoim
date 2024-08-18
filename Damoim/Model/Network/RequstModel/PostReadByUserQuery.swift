//
//  PostReadByUserQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/18/24.
//

import Foundation

struct PostReadByUserQuery: Encodable {
    let userId: String
    let next: String?
    let limit: String?
    let product_id: String?
}
