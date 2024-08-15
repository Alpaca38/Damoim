//
//  NetworkManager.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import Foundation
import Alamofire
import RxSwift

final class NetworkManager {
    private init() { }
    static let shared = NetworkManager()
    
    func signUp(email: String, password: String, nick: String) -> Single<Result<String, APIError>> {
        return Single.create { observer in
            do {
                let query = SignUpQuery(email: email, password: password, nick: nick)
                let request = try Router.signUp(query: query).asURLRequest()
                AF.request(request)
                    .validate() // 없으니까 계속 success로 인식함, responseDecodable 일때는 없어도 괜찮음
                    .response { response in
                        switch response.result {
                        case .success(_):
                            observer(.success(.success(l10nKey.signUpSuccess.rawValue.localized)))
                        case .failure(_):
                            switch response.response?.statusCode {
                            case 400:
                                observer(.success(.failure(.invalidRequestVariables)))
                            case 409:
                                observer(.success(.failure(.conflict)))
                            default:
                                observer(.success(.failure(.serverError)))
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    func login(email: String, password: String) -> Single<Result<Login, APIError>> {
        return Single.create { observer in
            do {
                let query = LoginQuery(email: email, password: password)
                let request = try Router.login(query: query).asURLRequest()
                AF.request(request)
                    .responseDecodable(of: Login.self) { response in
                        switch response.result {
                        case .success(let success):
                            observer(.success(.success(success)))
                            UserDefaultsManager.accessToken = success.accessToken
                            UserDefaultsManager.refreshToken = success.refreshToken
                            UserDefaultsManager.isLogin = true
                        case .failure(_):
                            switch response.response?.statusCode {
                            case 400:
                                observer(.success(.failure(.invalidRequestVariables)))
                            case 401:
                                observer(.success(.failure(.invalidRequest)))
                            default:
                                observer(.success(.failure(.serverError)))
                            }
                            
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
        
    }
    
    func refreshToken() -> Single<Result<Refresh, APIError>> {
        return Single.create { observer in
            do {
                let request = try Router.refresh.asURLRequest()
                AF.request(request)
                    .responseDecodable(of: Refresh.self) { response in
                        switch response.result {
                        case .success(let success):
                            observer(.success(.success(success)))
                            UserDefaultsManager.accessToken = success.accessToken
                        case .failure(_):
                            switch response.response?.statusCode {
                            case 401:
                                observer(.success(.failure(.invalidRequest)))
                            case 403:
                                observer(.success(.failure(.forbidden)))
                            case 418:
                                observer(.success(.failure(.refreshTokenExpired))) // 로그인 화면으로 전환
                                UserDefaultsManager.isLogin = false
                            default:
                                observer(.success(.failure(.serverError)))
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
}
