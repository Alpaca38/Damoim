//
//  LoginViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let loginResult = input.loginTap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(input.email, input.password))
            .flatMap { email, password in
                NetworkManager.shared.login(email: email, password: password)
            }
            .asDriver(onErrorJustReturn: (.failure(.serverError)))
        
        return Output(loginResult: loginResult)
    }
}

extension LoginViewModel {
    struct Input {
        let loginTap: ControlEvent<Void>
        let email: ControlProperty<String>
        let password: ControlProperty<String>
    }
    
    struct Output {
        let loginResult: Driver<Result<Login, APIError>>
    }
}
