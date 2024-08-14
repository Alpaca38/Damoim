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
}
