//
//  Router.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import Foundation
import Alamofire

enum ServerRouter {
    case signUp(query: SignUpQuery)
    case emailValdation(query: EmailValidationQuery)
    case login(query: LoginQuery)
    case refresh
    
    case fetchMyProfile
    case fetchOtherUserProfile(query: OtherUserProfileQuery)
    
    case follow(query: FollowQuery)
    case unfollow(query: UnFollowQuery)
    
    case postRead(query: PostReadQuery)
    case postReadByUser(query: PostReadByUserQuery)
    case specificPost(query: SpecificPostQuery)
    case like(query: LikeQuery)
    case like2(query: LikeQuery)
    
    case comment(query: CommentQuery)
    
    case fetchImage(query: FetchImageQuery)
}

extension ServerRouter: TargetType {
    var baseURL: String {
        return APIKey.sesacBaseURL
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .signUp:
            return .post
        case .emailValdation:
            return .post
        case .login:
            return .post
        case .refresh:
            return .get
        case .fetchMyProfile, .fetchOtherUserProfile:
            return .get
        case .postRead, .postReadByUser:
            return .get
        case .fetchImage:
            return .get
        case .specificPost:
            return .get
        case .like, .like2:
            return .post
        case .comment:
            return .post
        case .follow:
            return .post
        case .unfollow:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .signUp:
            "users/join"
        case .emailValdation:
            "validation/email"
        case .login:
            "users/login"
        case .refresh:
            "auth/refresh"
        case .fetchMyProfile:
            "users/me/profile"
        case .postRead:
            "posts/"
        case .postReadByUser(let query):
            "posts/users/\(query.userId)"
        case .fetchImage(let query):
            query.parameter
        case .specificPost(let query):
            "posts/\(query.postId)"
        case .like(let query):
            "posts/\(query.postId)/like"
        case .like2(let query):
            "posts/\(query.postId)/like-2"
        case .comment(let query):
            "posts/\(query.postId)/comments"
        case .fetchOtherUserProfile(let query):
            "users/\(query.userId)/profile"
        case .follow(let query):
            "follow/\(query.userId)"
        case .unfollow(let query):
            "follow/\(query.userId)"
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
        case .postRead, .fetchMyProfile, .fetchImage, .specificPost, .postReadByUser, .fetchOtherUserProfile, .follow, .unfollow:
            [
                Header.authorization.rawValue: UserDefaultsManager.accessToken,
                Header.sesacKey.rawValue: APIKey.sesacKey
            ]
        case .like, .like2, .comment:
            [
                Header.authorization.rawValue: UserDefaultsManager.accessToken,
                Header.sesacKey.rawValue: APIKey.sesacKey,
                Header.contentType.rawValue: Header.json.rawValue
            ]
        }
    }
    
    var parameters: String? {
        nil
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .postRead(let query):
            [
                URLQueryItem(name: "next", value: query.next),
                URLQueryItem(name: "limit", value: query.limit),
                URLQueryItem(name: "product_id", value: query.product_id)
            ]
        case .postReadByUser(let query):
            [
                URLQueryItem(name: "next", value: query.next),
                URLQueryItem(name: "limit", value: query.limit),
                URLQueryItem(name: "product_id", value: query.product_id)
            ]
        default:
            nil
        }
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
        case .like(let query):
            return try? encoder.encode(["like_status": query.like_status])
        case .like2(let query):
            return try? encoder.encode(["like_status": query.like_status])
        case .comment(let query):
            return try? encoder.encode(["content": query.content])
        case .refresh, .postRead, .fetchImage, .fetchMyProfile, .specificPost, .postReadByUser, .fetchOtherUserProfile, .follow, .unfollow:
            return nil
        }
    }
}
