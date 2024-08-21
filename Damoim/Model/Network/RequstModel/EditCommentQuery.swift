//
//  EditCommentQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/21/24.
//

import Foundation

struct EditCommentQuery: Encodable {
    let postId: String
    let commentID: String
    let content: String
}
