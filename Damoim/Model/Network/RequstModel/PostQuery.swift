//
//  PostCreateQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct PostQuery: Encodable {
    let title: String
    let price: Int?
    let content: String
    let content1: String // 장소
    let content2: String // 일정
    let content3: String // 최대인원
    let content4: String // 위치 좌표
    let content5: String // 카테고리
    let product_id: String // 컨텐츠 구분
    let files: [String]
}
