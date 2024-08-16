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
        let post = PublishSubject<Post>()
        let errorRelay = PublishRelay<APIError>()
        
        let photoImageData = PublishSubject<Data>()
        let profileImageData = PublishSubject<Data>()
        let errorSubject = PublishSubject<AFError>()
        
        let isJoin = PublishSubject<Bool>()
        
        NetworkManager.shared.fetchSpecificPosts(postId: postItem.post_id) { result in
            switch result {
            case .success(let success):
                post.onNext(success)
            case .failure(let failure):
                errorRelay.accept(failure)
            }
        }
        
        post
            .bind { post in
                if let photoURL = post.files.first {
                    NetworkManager.shared.fetchImage(parameter: photoURL) { result in
                        switch result {
                        case .success(let success):
                            photoImageData.onNext(success)
                        case .failure(let failure):
                            errorSubject.onNext(failure)
                        }
                    }
                }
                
                if let profileImage = post.creator.profileImage {
                    NetworkManager.shared.fetchImage(parameter: profileImage) { result in
                        switch result {
                        case .success(let success):
                            profileImageData.onNext(success)
                        case .failure(let failure):
                            errorSubject.onNext(failure)
                        }
                    }
                }
                
                if post.creator.user_id == UserDefaultsManager.user_id {
                    isJoin.onNext(true)
                } else {
                    isJoin.onNext(false)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            post: post,
            photoImageData: photoImageData,
            profileImageData: profileImageData,
            errorSubject: errorSubject,
            isJoin: isJoin
        )
    }
}

extension ClubDetailViewModel {
    struct Input {
        let joinTap: ControlEvent<Void>
    }
    
    struct Output {
        let post: Observable<Post>
        let photoImageData: Observable<Data>
        let profileImageData: Observable<Data>
        let errorSubject: PublishSubject<AFError>
        let isJoin: Observable<Bool>
    }
}
