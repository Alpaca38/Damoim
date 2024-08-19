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
    
    func transform(input: Input) -> Output {
        let profileImageData = BehaviorSubject<Data?>(value: nil)
        let nick = BehaviorSubject(value: UserDefaultsManager.nickname)
        
        if let data = UserDefaultsManager.profileImageData {
            profileImageData.onNext(data)
        }
        
        let saveValid = input.nickText
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        return Output(
            profileImageData: profileImageData,
            nick: nick,
            saveValid: saveValid
        )
    }
}

extension EditProfileViewModel {
    struct Input {
        let nickText: ControlProperty<String>
        let saveTap: ControlEvent<Void>
    }
    
    struct Output {
        let profileImageData: BehaviorSubject<Data?>
        let nick: BehaviorSubject<String>
        let saveValid: Observable<Bool>
    }
}
