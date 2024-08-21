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
        let edit = PublishRelay<(String, Comment)>()
        let deleteCommentError = PublishRelay<APIError>()
        
        let isEmpty = comments
            .map { $0.isEmpty }
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                NetworkManager.shared.fetchSpecificPosts(postId: owner.postId) { result in
                    switch result {
                    case .success(let success):
                        comments.accept(success.comments.reversed())
                    case .failure(let failure):
                        fetchPostError.accept(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
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
        
        input.editTap
            .bind(with: self) { owner, commentID in
                edit.accept((owner.postId, commentID))
            }
            .disposed(by: disposeBag)
        
        input.deleteTap
            .bind(with: self) { owner, commentID in
                NetworkManager.shared.deleteComment(postId: owner.postId, commentID: commentID) { result in
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
                        deleteCommentError.accept(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            comments: comments,
            fetchPostError: fetchPostError,
            createCommentError: createCommentError,
            isEmpty: isEmpty,
            sendValid: sendValid,
            edit: edit,
            deleteCommentError: deleteCommentError
        )
    }
}

extension CommentViewModel {
    struct Input {
        let viewWillAppear: ControlEvent<Bool>
        let sendTap: ControlEvent<Void>
        let commentText: ControlProperty<String?>
        let editTap: PublishRelay<Comment>
        let deleteTap: PublishRelay<String>
    }
    
    struct Output {
        let comments: BehaviorRelay<[Comment]>
        let fetchPostError: PublishRelay<APIError>
        let createCommentError: PublishRelay<APIError>
        let isEmpty: Observable<Bool>
        let sendValid: Observable<Bool>
        let edit: PublishRelay<(String, Comment)>
        let deleteCommentError: PublishRelay<APIError>
    }
}
