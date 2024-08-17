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
        
        let isMine = PublishSubject<Bool>()
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
                    isMine.onNext(true)
                } else {
                    isMine.onNext(false)
                }
                
                if post.likes.contains(UserDefaultsManager.user_id) {
                    isJoin.onNext(true)
                } else {
                    isJoin.onNext(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.joinTap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(post)
            .bind(with: self, onNext: { owner, postData in
                if postData.likes.contains(UserDefaultsManager.user_id) {
                    NetworkManager.shared.join(postId: postData.post_id, like_status: false) { result in
                        switch result {
                        case .success(let success):
                            isJoin.onNext(success)
                            NetworkManager.shared.fetchSpecificPosts(postId: owner.postItem.post_id) { result in
                                switch result {
                                case .success(let success):
                                    post.onNext(success)
                                case .failure(let failure):
                                    errorRelay.accept(failure)
                                }
                            }
                        case .failure(let failure):
                            errorRelay.accept(failure)
                        }
                    }
                } else {
                    NetworkManager.shared.join(postId: postData.post_id, like_status: true) { result in
                        switch result {
                        case .success(let success):
                            isJoin.onNext(success)
                            NetworkManager.shared.fetchSpecificPosts(postId: owner.postItem.post_id) { result in
                                switch result {
                                case .success(let success):
                                    post.onNext(success)
                                case .failure(let failure):
                                    errorRelay.accept(failure)
                                }
                            }
                        case .failure(let failure):
                            errorRelay.accept(failure)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            post: post,
            photoImageData: photoImageData,
            profileImageData: profileImageData,
            errorSubject: errorSubject,
            errorRelay: errorRelay,
            isMine: isMine,
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
        let errorRelay: PublishRelay<APIError>
        let isMine: Observable<Bool>
        let isJoin: PublishSubject<Bool>
    }
}