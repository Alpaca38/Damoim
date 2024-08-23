//
//  APIError.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

enum LSLPAPIError: String, Error {
    case invalidRequestVariables = "잘못된 요청입니다. 필수값을 채워주세요." // 400
    case invalidRequest = "유효하지 않은 요청입니다." // 401, invalidToken
    case nicknameWithWhiteSpace = "공백이 포함된 닉네임은 사용할 수 없습니다." // 402
    case forbidden = "접근 권한이 없습니다." // 403
    case conflict = "이미 가입한 유저입니다." // 409
    case databaseError = "데이터베이스에 접근할 수 없습니다." // 410
    case refreshTokenExpired = "리프레시 토큰이 만료되었습니다. 다시 로그인 해주세요." // 418
    case accessTokenExpired = "엑세스 토큰이 만료되었습니다." // 419
    case failedAuthentication = "This service sesac_memolease only" // 420
    case tooManyRequest = "과호출입니다." // 429
    case invalidURL = "비정상적인 URL 입니다." // 444
    case invalidAuthentication = "권한이 없습니다." // 445
    case serverError = "서버 에러 입니다." // 500
}
