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
                            case 402:
                                observer(.success(.failure(.nicknameWithWhiteSpace)))
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
        return Single.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            
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
                            UserDefaultsManager.nickname = success.nick
                            UserDefaultsManager.isLogin = true
                            if let profileURL = success.profileImage {
                                self.fetchImage(parameter: profileURL) { result in
                                    switch result {
                                    case .success(let success):
                                        UserDefaultsManager.profileImageData = success
                                    case .failure(let failure):
                                        print(failure)
                                    }
                                }
                            }
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
    func fetchMyProfile(completion: @escaping (Result<Profile, APIError>) -> Void) {
        do {
            let request = try  ServerRouter.fetchMyProfile.asURLRequest()
            AF.request(request)
                .responseDecodable(of: Profile.self) { [weak self] response in
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
                                    self.fetchMyProfile { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func fetchOtherUserProfile(userId: String, completion: @escaping (Result<Profile, APIError>) -> Void) {
        do {
            let query = OtherUserProfileQuery(userId: userId)
            let request = try ServerRouter.fetchOtherUserProfile(query: query).asURLRequest()
            AF.request(request)
                .responseDecodable(of: Profile.self) { [weak self] response in
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
                                    self.fetchOtherUserProfile(userId: userId) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func editProfile(nick: String, profile: Data?, completion: @escaping (Result<Profile, APIError>) -> Void) {
        do {
            let request = try ServerRouter.editProfile.asURLRequest()
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(nick.data(using: .utf8)!, withName: "nick")
                if let profile {
                    multipartFormData.append(profile, withName: "profile", fileName: "profile.png", mimeType: "image/png")
                }
            }, with: request)
                .responseDecodable(of: Profile.self) { [weak self] response in
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
                        case 402:
                            completion(.failure(.nicknameWithWhiteSpace))
                        case 403:
                            completion(.failure(.forbidden))
                        case 409:
                            completion(.failure(.conflict))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.editProfile(nick: nick, profile: profile) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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

// MARK: 팔로우
extension NetworkManager {
    func follow(userId: String, completion: @escaping (Result<Data, APIError>) -> Void) {
        do {
            let query = FollowQuery(userId: userId)
            let request = try ServerRouter.follow(query: query).asURLRequest()
            AF.request(request)
                .validate()
                .responseData { [weak self] response in
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
                        case 409:
                            completion(.failure(.conflict))
                        case 410:
                            completion(.failure(.databaseError))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.follow(userId: userId) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func unfollow(userId: String, completion: @escaping (Result<Data, APIError>) -> Void) {
        do {
            let query = UnFollowQuery(userId: userId)
            let request = try ServerRouter.unfollow(query: query).asURLRequest()
            AF.request(request)
                .validate()
                .responseData { [weak self] response in
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
                        case 410:
                            completion(.failure(.databaseError))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.unfollow(userId: userId) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func fetchPostsByUser(userId: String, next: String?, completion: @escaping (Result<Posts, APIError>) -> Void) {
        do {
            let query = PostReadByUserQuery(userId: userId, next: next, limit: nil, product_id: nil)
            let request = try ServerRouter.postReadByUser(query: query).asURLRequest()
            AF.request(request)
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
                                    self.fetchPostsByUser(userId: userId, next: next) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func join(postId: String, like_status: Bool, completion: @escaping (Result<Bool, APIError>) -> Void) {
        do {
            let query = LikeQuery(postId: postId, like_status: like_status)
            let request = try ServerRouter.like(query: query).asURLRequest()
            AF.request(request)
                .validate()
                .response { [weak self] response in
                    guard let self else { return }
                    switch response.result {
                    case .success(_):
                        completion(.success(like_status))
                    case .failure(_):
                        switch response.response?.statusCode {
                        case 400:
                            completion(.failure(.invalidRequestVariables))
                        case 401:
                            completion(.failure(.invalidRequest))
                        case 403:
                            completion(.failure(.forbidden))
                        case 410:
                            completion(.failure(.databaseError))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.join(postId: postId, like_status: like_status) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func fetchJoinedPost(next: String?, limit: String?, completion: @escaping (Result<Posts, APIError>) -> Void) {
        do {
            let query = FetchLikePostQuery(next: next, limit: limit)
            let request = try ServerRouter.fetchLikePost(query: query).asURLRequest()
            AF.request(request)
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
                                    self.fetchJoinedPost(next: next, limit: limit) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func like(postId: String, like_status: Bool, completion: @escaping (Result<Bool, APIError>) -> Void) {
        do {
            let query = LikeQuery(postId: postId, like_status: like_status)
            let request = try ServerRouter.like2(query: query).asURLRequest()
            AF.request(request)
                .validate()
                .response { [weak self] response in
                    guard let self else { return }
                    switch response.result {
                    case .success(_):
                        completion(.success(like_status))
                    case .failure(_):
                        switch response.response?.statusCode {
                        case 400:
                            completion(.failure(.invalidRequestVariables))
                        case 401:
                            completion(.failure(.invalidRequest))
                        case 403:
                            completion(.failure(.forbidden))
                        case 410:
                            completion(.failure(.databaseError))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.join(postId: postId, like_status: like_status) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func fetchLikedPost(next: String?, limit: String?, completion: @escaping (Result<Posts, APIError>) -> Void) {
        do {
            let query = FetchLikePostQuery(next: next, limit: limit)
            let request = try ServerRouter.fetchLike2Post(query: query).asURLRequest()
            AF.request(request)
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
                                    self.fetchLikedPost(next: next, limit: limit) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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

// MARK: 댓글
extension NetworkManager {
    func createComment(postId: String, content: String, completion: @escaping (Result<Comment, APIError>) -> Void) {
        do {
            let query = CommentQuery(postId: postId, content: content)
            let request = try ServerRouter.comment(query: query).asURLRequest()
            AF.request(request)
                .responseDecodable(of: Comment.self) { [weak self] response in
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
                        case 410:
                            completion(.failure(.databaseError))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.createComment(postId: postId, content: content) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
    
    func editComment(postId: String, commentID: String, content: String, completion: @escaping (Result<Comment, APIError>) -> Void) {
        do {
            let query = EditCommentQuery(postId: postId, commentID: commentID, content: content)
            let request = try ServerRouter.editComment(query: query).asURLRequest()
            AF.request(request)
                .responseDecodable(of: Comment.self) { [weak self] response in
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
                        case 410:
                            completion(.failure(.databaseError))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.editComment(postId: postId, commentID: commentID, content: content) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
                                    if failure == .refreshTokenExpired {
                                        completion(.failure(.refreshTokenExpired))
                                    }
                                }
                            })
                        case 445:
                            completion(.failure(.invalidAuthentication))
                        default:
                            completion(.failure(.serverError))
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func deleteComment(postId: String, commentID: String, completion: @escaping (Result<Data?, APIError>) -> Void) {
        do {
            let query = DeleteCommentQuery(postId: postId, commentID: commentID)
            let request = try ServerRouter.deleteComment(query: query).asURLRequest()
            AF.request(request)
                .validate()
                .response { [weak self] response in
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
                        case 410:
                            completion(.failure(.databaseError))
                        case 419:
                            refreshToken(completion: { result in // 토큰 갱신
                                switch result {
                                case .success(_):
                                    self.deleteComment(postId: postId, commentID: commentID) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
                                    if failure == .refreshTokenExpired {
                                        completion(.failure(.refreshTokenExpired))
                                    }
                                }
                            })
                        case 445:
                            completion(.failure(.invalidAuthentication))
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

// MARK: HashTag Search
extension NetworkManager {
    func searchHashTag(next: String?, limit: String?, product_id: String?, hashTag: String?, completion: @escaping (Result<Posts, APIError>) -> Void) {
        do {
            let query = HashTagSearchQuery(next: next, limit: limit, product_id: product_id, hashTag: hashTag)
            let request = try ServerRouter.searchHashTag(query: query).asURLRequest()
            AF.request(request)
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
                                    self.searchHashTag(next: next, limit: limit, product_id: product_id, hashTag: hashTag) { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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

// MARK: 회원 탈퇴
extension NetworkManager {
    func withdraw(completion: @escaping (Result<Data?, APIError>) -> Void) {
        do {
            let request = try ServerRouter.withdraw.asURLRequest()
            AF.request(request)
                .validate()
                .response { [weak self] response in
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
                                    self.withdraw { result in
                                        switch result {
                                        case .success(let success):
                                            completion(.success(success))
                                        case .failure(let failure):
                                            completion(.failure(failure))
                                        }
                                    }
                                case .failure(let failure):
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
