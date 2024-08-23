//
//  NaverSearchAPIError.swift
//  Damoim
//
//  Created by 조규연 on 8/22/24.
//

import Foundation

enum NaverSearchAPIError: String, Error {
    case invalidRequest = "잘못된 요청입니다." // 400
    case invalidSearchAPI = "API 요청 URL에 문제가 있는지 확인해 보세요." // 404
    case serverError = "서버 내부에 오류가 발생했습니다."
}
