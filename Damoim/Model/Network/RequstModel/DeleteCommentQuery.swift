//
//  DeleteCommentQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/21/24.
//

import Foundation

struct DeleteCommentQuery: Encodable {
    let postId: String
    let commentID: String
}
