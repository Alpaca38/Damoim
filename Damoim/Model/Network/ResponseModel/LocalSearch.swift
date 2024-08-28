//
//  LocalSearch.swift
//  Damoim
//
//  Created by 조규연 on 8/22/24.
//

import Foundation

struct LocalSearch: Decodable {
    let items: [LocalSearchItem]
}

struct LocalSearchItem: Decodable {
    let title: String
    let roadAddress: String
    let mapx: String
    let mapy: String
}
