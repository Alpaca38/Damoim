//
//  Router.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import Foundation
import Alamofire

enum Router {
    case signUp(query: SignUpQuery)
    case emailValdation(query: EmailValidationQuery)
    case login(query: LoginQuery)
    case refresh
}

extension Router: TargetType {
    var baseURL: String {
        return APIKey.sesacBaseURL
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .signUp:
            return .post
        case .emailValdation:
            return .post
        case .login(let query):
            return .post
        case .refresh:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .signUp:
            "/users/join"
        case .emailValdation:
            "/validation/email"
        case .login:
            "/users/login"
        case .refresh:
            "/auth/refresh"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .signUp, .emailValdation, .login:
            [
                Header.contentType.rawValue: Header.json.rawValue,
                Header.sesacKey.rawValue: APIKey.sesacKey
            ]
        case .refresh:
            [
                Header.authorization.rawValue: UserDefaultsManager.accessToken,
                Header.sesacKey.rawValue: APIKey.sesacKey,
                Header.refresh.rawValue: UserDefaultsManager.refreshToken
            ]
        }
    }
    
    var parameters: String? {
        nil
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .signUp(let query):
            return try? encoder.encode(query)
        case .emailValdation(let query):
            return try? encoder.encode(query)
        case .login(let query):
            return try? encoder.encode(query)
        case .refresh:
            return nil
        }
    }
    
    
}
