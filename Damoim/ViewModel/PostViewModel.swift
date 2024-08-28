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
    private let location: LocalSearchItem
    private let category: CategoryViewModel.Category
    private let disposeBag = DisposeBag()
    
    init(location: LocalSearchItem, category: CategoryViewModel.Category) {
        self.location = location
        self.category = category
    }
    
    func transform(input: Input) -> Output {
        let location = Observable.just(location)
        let category = Observable.just(category)
        
        let imageUploadError = PublishSubject<LSLPAPIError>()
        let createPostSuccess = PublishSubject<Void>()
        let createPostError = PublishSubject<LSLPAPIError>()
        let joinError = PublishSubject<LSLPAPIError>()
        
        let createValid = Observable.combineLatest(input.titleText, input.maxCount, input.deadline, input.price, input.imageData, input.contentText)
            .map { !$0.0.isEmpty && $0.1 != l10nKey.buttonMaxCount.rawValue.localized && $0.2 != l10nKey.buttonDeadline.rawValue.localized && !$0.3.isEmpty && $0.4 != nil && !$0.5.isEmpty && $0.5 != l10nKey.placeholderContent.rawValue.localized }
        
        input.createPostTap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(location, category, input.imageData, input.titleText, input.contentText, input.maxCount, input.deadline, input.price))
            .bind(with: self, onNext: { owner, value in
                guard let imageData = value.2 else { return }
                let price = value.7 == "0" ? nil : Int(value.7)
                
                NetworkManager.shared.imageUpload(files: imageData) { result in
                    switch result {
                    case .success(let success):
                        NetworkManager.shared.createPost(title: value.3, price: price, content: value.4, content1: value.0.roadAddress, content2: value.6, content3: value.5, content4: "\(value.0.mapx) \(value.0.mapy)", content5: value.1.rawValue, product_id: value.1.product_id, files: success) { result in
                            switch result {
                            case .success(let success):
                                NetworkManager.shared.join(postId: success.post_id, like_status: true) { result in
                                    switch result {
                                    case .success(_):
                                        createPostSuccess.onNext(())
                                    case .failure(let failure):
                                        joinError.onNext(failure)
                                    }
                                }
                            case .failure(let failure):
                                createPostError.onNext(failure)
                            }
                        }
                    case .failure(let failure):
                        imageUploadError.onNext(failure)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            createValid: createValid,
            imageUploadError: imageUploadError,
            createPostSuccess: createPostSuccess,
            createPostError: createPostError,
            joinError: joinError
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
        let imageUploadError: PublishSubject<LSLPAPIError>
        let createPostSuccess: PublishSubject<Void>
        let createPostError: PublishSubject<LSLPAPIError>
        let joinError: PublishSubject<LSLPAPIError>
    }
}
