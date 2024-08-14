//
//  Login.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct Login: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
}
