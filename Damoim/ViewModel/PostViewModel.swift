//
//  PostViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostViewModel: ViewModel {
    private let location: String
    private let category: String
    private let disposeBag = DisposeBag()
    
    init(location: String, category: String) {
        self.location = location
        self.category = category
    }
    
    func transform(input: Input) -> Output {
        input.createPostTap
            .bind(with: self) { owner, _ in
                print("tap")
            }
            .disposed(by: disposeBag)
        
        let createValid = Observable.combineLatest(input.titleText, input.maxCount, input.deadline, input.price)
            .map { !$0.0.isEmpty && $0.1 != l10nKey.buttonMaxCount.rawValue.localized && $0.2 != l10nKey.buttonDeadline.rawValue.localized && !$0.3.isEmpty }
        
        return Output(
            createValid: createValid
        )
    }
    
    
}

extension PostViewModel {
    struct Input {
        let imageData: Observable<Data?>
        let titleText: ControlProperty<String>
        let contentText: ControlProperty<String>
        let maxCount: PublishSubject<String>
        let deadline: PublishSubject<String>
        let price: ControlProperty<String>
        let createPostTap: ControlEvent<Void>
    }
    
    struct Output {
        let createValid: Observable<Bool>
    }
}
