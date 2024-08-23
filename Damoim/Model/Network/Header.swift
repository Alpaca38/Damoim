//
//  Header.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

enum Header: String {
    case authorization = "Authorization"
    case sesacKey = "SesacKey"
    case contentType = "Content-Type"
    case json = "application/json"
    case refresh = "Refresh"
    case multipart = "multipart/form-data"
    
    case naverClientID = "X-Naver-Client-Id"
    case naverClientSecret = "X-Naver-Client-Secret"
}
