//
//  UserDefaultsManager.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

struct UserDefaultsManager {
    private init() { }
    
    @UserDefault(key: .accessToken, defaultValue: "", isCustomObject: false)
    static var accessToken: String
    
    @UserDefault(key: .refreshToken, defaultValue: "", isCustomObject: false)
    static var refreshToken: String
    
    @UserDefault(key: .isLogin, defaultValue: false, isCustomObject: false)
    static var isLogin: Bool
    
    @UserDefault(key: .user_id, defaultValue: "", isCustomObject: false)
    static var user_id: String
    
    @UserDefault(key: .profileImageData, defaultValue: nil, isCustomObject: false)
    static var profileImageData: Data?
    
    @UserDefault(key: .nickname, defaultValue: "", isCustomObject: false)
    static var nickname: String
}
