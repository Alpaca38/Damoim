//
//  SignUpViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let totalValid = BehaviorSubject(value: false)
        
        let emailValid = input.email
            .map { !$0.isEmpty }
            
        let nicknameValid = input.nickname
            .map { !$0.isEmpty }
        
        let passwordValid = input.password
            .map { !$0.isEmpty }
        
        Observable.combineLatest(emailValid, nicknameValid, passwordValid)
            .map { $0.0 && $0.1 && $0.2 }
            .bind(to: totalValid)
            .disposed(by: disposeBag)
        
        
        let signUpResult = input.signUpTap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(input.email, input.password, input.nickname))
            .flatMap { email, password, nickname in
                NetworkManager.shared.signUp(email: email, password: password, nick: nickname)
            }
            .asDriver(onErrorJustReturn: (.failure(.serverError)))
        
        
        return Output(
            signUpResult: signUpResult,
            totalValid: totalValid
        )
    }
    
    
}

extension SignUpViewModel {
    struct Input {
        let signUpTap: ControlEvent<Void>
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let nickname: ControlProperty<String>
    }
    
    struct Output {
        let signUpResult: Driver<Result<String, LSLPAPIError>>
        let totalValid: Observable<Bool>
    }
}
