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
                    .validate() // 없으니까 계속 success로 인식함
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
}
