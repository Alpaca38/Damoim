//
//  ClubDetailViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/16/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

final class ClubDetailViewModel: ViewModel {
    private let postItem: PostItem
    private let disposeBag = DisposeBag()
    
    init(postItem: PostItem) {
        self.postItem = postItem
    }
    
    func transform(input: Input) -> Output {
        let postItem = BehaviorSubject(value: postItem)
        let photoImageData = PublishSubject<Data>()
        let profileImageData = PublishSubject<Data>()
        let errorSubject = PublishSubject<AFError>()
        
        postItem
            .bind { postItem in
                if let photoURL = postItem.files.first {
                    NetworkManager.shared.fetchImage(parameter: photoURL) { result in
                        switch result {
                        case .success(let success):
                            photoImageData.onNext(success)
                        case .failure(let failure):
                            errorSubject.onNext(failure)
                        }
                    }
                }
                
                if let profileImage = postItem.creator.profileImage {
                    NetworkManager.shared.fetchImage(parameter: profileImage) { result in
                        switch result {
                        case .success(let success):
                            profileImageData.onNext(success)
                        case .failure(let failure):
                            errorSubject.onNext(failure)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            postItem: postItem,
            photoImageData: photoImageData,
            profileImageData: profileImageData,
            errorSubject: errorSubject
        )
    }
}

extension ClubDetailViewModel {
    struct Input {
        
    }
    
    struct Output {
        let postItem: Observable<PostItem>
        let photoImageData: Observable<Data>
        let profileImageData: Observable<Data>
        let errorSubject: PublishSubject<AFError>
    }
}
