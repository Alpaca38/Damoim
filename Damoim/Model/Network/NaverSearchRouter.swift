//
//  NaverSearchRouter.swift
//  Damoim
//
//  Created by 조규연 on 8/22/24.
//

import Foundation
import Alamofire

enum NaverSearchRouter {
    case LocalSearch(query: LocalSearchQuery)
}

extension NaverSearchRouter: TargetType {
    var baseURL: String {
        APIKey.naverBaseURL
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .LocalSearch:
                .get
        }
    }
    
    var path: String {
        switch self {
        case .LocalSearch:
            "/v1/search/local.json"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .LocalSearch:
            [
                Header.naverClientID.rawValue: APIKey.naverId,
                Header.naverClientSecret.rawValue: APIKey.naverSecret
            ]
        }
    }
    
    var parameters: String? {
        nil
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .LocalSearch(let query):
            [
                URLQueryItem(name: "query", value: query.query),
                URLQueryItem(name: "display", value: String(query.display))
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .LocalSearch:
            nil
        }
    }
}
