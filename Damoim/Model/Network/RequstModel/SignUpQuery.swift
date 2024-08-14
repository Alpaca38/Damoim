//
//  JoinQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct SignUpQuery: Encodable {
    let email: String
    let password: String
    let nick: String
}
