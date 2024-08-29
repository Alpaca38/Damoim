//
//  Payments.swift
//  Damoim
//
//  Created by 조규연 on 8/29/24.
//

import Foundation

struct Payments: Decodable {
    let buyer_id: String
    let post_id: String
    let merchant_uid: String
    let productName: String
    let price: Int
    let paidAt: String
}
