//
//  CommentViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentViewModel: ViewModel {
    private let postId: String
    private let disposeBag = DisposeBag()
    
    init(postId: String) {
        self.postId = postId
    }
    
    func transform(input: Input) -> Output {
        let comments = BehaviorRelay<[Comment]>(value: [])
        let fetchPostError = PublishRelay<APIError>()
        let createCommentError = PublishRelay<APIError>()
        
        let isEmpty = comments
            .map { $0.isEmpty }
        
        NetworkManager.shared.fetchSpecificPosts(postId: postId) { result in
            switch result {
            case .success(let success):
                comments.accept(success.comments.reversed())
            case .failure(let failure):
                fetchPostError.accept(failure)
            }
        }
        
        let sendValid = input.commentText.orEmpty
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        input.sendTap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(input.commentText.orEmpty)
            .distinctUntilChanged()
            .bind(with: self) { owner, comment in
                input.commentText.onNext(nil)
                NetworkManager.shared.createComment(postId: owner.postId, content: comment) { result in
                    switch result {
                    case .success(_):
                        NetworkManager.shared.fetchSpecificPosts(postId: owner.postId) { result in
                            switch result {
                            case .success(let success):
                                comments.accept(success.comments.reversed())
                            case .failure(let failure):
                                fetchPostError.accept(failure)
                            }
                        }
                    case .failure(let failure):
                        createCommentError.accept(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            comments: comments,
            fetchPostError: fetchPostError,
            createCommentError: createCommentError,
            isEmpty: isEmpty,
            sendValid: sendValid
        )
    }
}

extension CommentViewModel {
    struct Input {
        let sendTap: ControlEvent<Void>
        let commentText: ControlProperty<String?>
    }
    
    struct Output {
        let comments: BehaviorRelay<[Comment]>
        let fetchPostError: PublishRelay<APIError>
        let createCommentError: PublishRelay<APIError>
        let isEmpty: Observable<Bool>
        let sendValid: Observable<Bool>
    }
}
