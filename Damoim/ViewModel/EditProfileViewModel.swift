//
//  EditProfileViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/19/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EditProfileViewModel: ViewModel {
    let imagePicked = BehaviorSubject<Data?>(value: nil)
    private var sendProfile: ((Profile) -> Void)?
    
    init(sendProfile: @escaping (Profile) -> Void) {
        self.sendProfile = sendProfile
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let profileImageData = BehaviorSubject<Data?>(value: nil)
        let nick = BehaviorSubject(value: UserDefaultsManager.nickname)
        let editSuccess = PublishSubject<Profile>()
        let editError = PublishSubject<APIError>()
        
        if let data = UserDefaultsManager.profileImageData {
            profileImageData.onNext(data)
        }
        
        let saveValid = input.nickText.orEmpty
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        input.saveTap
            .withLatestFrom(Observable.combineLatest(input.nickText.orEmpty, imagePicked))
            .bind(with: self) { owner, value in
                NetworkManager.shared.editProfile(nick: value.0, profile: value.1) { result in
                    switch result {
                    case .success(let success):
                        editSuccess.onNext(success)
                        owner.sendProfile?(success)
                        UserDefaultsManager.nickname = success.nick
                        if let profileURL = success.profileImage {
                            NetworkManager.shared.fetchImage(parameter: profileURL) { result in
                                switch result {
                                case .success(let success):
                                    UserDefaultsManager.profileImageData = success
                                case .failure(let failure):
                                    print(failure)
                                }
                            }
                        }
                    case .failure(let failure):
                        editError.onNext(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            profileImageData: profileImageData,
            nick: nick,
            saveValid: saveValid,
            editSuccess: editSuccess,
            editError: editError
        )
    }
}

extension EditProfileViewModel {
    struct Input {
        let nickText: ControlProperty<String?>
        let saveTap: ControlEvent<Void>
    }
    
    struct Output {
        let profileImageData: BehaviorSubject<Data?>
        let nick: BehaviorSubject<String>
        let saveValid: Observable<Bool>
        let editSuccess: Observable<Profile>
        let editError: Observable<APIError>
    }
}
