//
//  ProfileEditQuery.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct ProfileEditQuery: Encodable {
    let nick: String?
    let profile: Data?
}
