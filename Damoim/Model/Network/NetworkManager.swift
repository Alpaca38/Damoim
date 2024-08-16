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
}

// MARK: 회원 인증
extension NetworkManager {
    func signUp(email: String, password: String, nick: String) -> Single<Result<String, APIError>> {
        return Single.create { observer in
            do {
                let query = SignUpQuery(email: email, password: password, nick: nick)
                let request = try ServerRouter.signUp(query: query).asURLRequest()
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
                let request = try ServerRouter.login(query: query).asURLRequest()
                AF.request(request)
                    .responseDecodable(of: Login.self) { response in
                        switch response.result {
                        case .success(let success):
                            observer(.success(.success(success)))
                            UserDefaultsManager.accessToken = success.accessToken
                            UserDefaultsManager.refreshToken = success.refreshToken
                            UserDefaultsManager.user_id = success.user_id
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
}

// MARK: 토큰 갱신
extension NetworkManager {
    func refreshToken(completion: @escaping (Result<Refresh, APIError>) -> Void){
        do {
            let request = try ServerRouter.refresh.asURLRequest()
            AF.request(request)
                .responseDecodable(of: Refresh.self) { response in
                    switch response.result {
                    case .success(let success):
                        UserDefaultsManager.accessToken = success.accessToken
                        completion(.success(success))
                    case .failure(_):
                        switch response.response?.statusCode {
                        case 401:
                            completion(.failure(.invalidRequest))
                        case 403:
                            completion(.failure(.forbidden))
                        case 418:
                            completion(.failure(.refreshTokenExpired)) // 로그인 화면으로 전환
                            UserDefaultsManager.isLogin = false
                        default:
                            print(APIError.serverError.rawValue)
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
}

// MARK: 프로필
extension NetworkManager {
    //    func fetchProfile() {
    //        do {
    //            let request = try  ServerRouter.fetchMyProfile.asURLRequest()
    //            AF.request(request)
    //                .responseDecodable(of: Profile.self) { [weak self] response in
    //                    if response.response?.statusCode == 419 {
    //                        self?.refreshToken()
    //                    }
    //                    switch response.result {
    //                    case .success(let success):
    //                        <#code#>
    //                    case .failure(_):
    //                        <#code#>
    //                    }
    //                }
    //        } catch {
    //            print(error)
    //        }
    //    }
}

// MARK: 포스트
extension NetworkManager {
    func fetchPosts(next: String?, product_id: String?, completion: @escaping (Result<Posts, APIError>) -> Void) {
        do {
            let query = PostReadQuery(next: next, limit: nil, product_id: product_id)
            let request = try ServerRouter.postRead(query: query).asURLRequest()
            AF.request(request)
                .validate()
                .responseDecodable(of: Posts.self) { [weak self] response in
                    guard let self else { return }
                    switch response.result {
                    case .success(let success):
                        completion(.success(success))
                    case .failure(_):
                        switch response.response?.statusCode {
                        case 400:
                            completion(.failure(.invalidRequestVariables))
                        case 401:
                            completion(.failure(.invalidRequest))
                        case 403:
                            completion(.failure(.forbidden))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.fetchPosts(next: next, product_id: product_id) { result in // 갱신 성공 시 다시 fetchposts
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
                                    print(failure.rawValue)
                                    if failure == .refreshTokenExpired {
                                        completion(.failure(.refreshTokenExpired))
                                    }
                                }
                            })
                        default:
                            completion(.failure(.serverError))
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func fetchSpecificPosts(postId: String, completion: @escaping (Result<Post, APIError>) -> Void) {
        do {
            let query = SpecificPostQuery(postId: postId)
            let request = try ServerRouter.specificPost(query: query).asURLRequest()
            AF.request(request)
                .responseDecodable(of: Post.self) { [weak self] response in
                    guard let self else { return }
                    switch response.result {
                    case .success(let success):
                        completion(.success(success))
                    case .failure(_):
                        switch response.response?.statusCode {
                        case 400:
                            completion(.failure(.invalidRequestVariables))
                        case 401:
                            completion(.failure(.invalidRequest))
                        case 403:
                            completion(.failure(.forbidden))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.fetchSpecificPosts(postId: postId) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
                                    print(failure.rawValue)
                                    if failure == .refreshTokenExpired {
                                        completion(.failure(.refreshTokenExpired))
                                    }
                                }
                            })
                        default:
                            completion(.failure(.serverError))
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
}

// MARK: 이미지 조회
extension NetworkManager {
    func fetchImage(parameter: String, completion: @escaping (Result<Data, AFError>) -> Void) {
        do {
            let query = FetchImageQuery(parameter: parameter)
            let request = try ServerRouter.fetchImage(query: query).asURLRequest()
            AF.request(request)
                .responseData { response in
                    switch response.result {
                    case .success(let success):
                        completion(.success(success))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        } catch {
            print(error)
        }
    }
}
