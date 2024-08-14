//
//  PostReadQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct PostReadQuery: Encodable { // query string
    let next: String?
    let limit: String?
    let product_id: String?
}
