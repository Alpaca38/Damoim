//
//  EditCommentViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EditCommentViewModel: ViewModel {
    private let postId: String
    private let comment: Comment
    private let disposeBag = DisposeBag()
    
    init(postId: String, comment: Comment) {
        self.postId = postId
        self.comment = comment
    }
    
    func transform(input: Input) -> Output {
        let content = BehaviorSubject(value: comment.content)
        let editSuccess = PublishSubject<Comment>()
        let editError = PublishSubject<LSLPAPIError>()
        
        let editValid = input.editText
            .map { !$0.isEmpty }
        
        input.editTap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(input.editText)
            .bind(with: self) { owner, editText in
                NetworkManager.shared.editComment(postId: owner.postId, commentID: owner.comment.comment_id, content: editText) { result in
                    switch result {
                    case .success(let success):
                        editSuccess.onNext(success)
                    case .failure(let failure):
                        editError.onNext(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            content: content,
            editValid: editValid,
            editSuccess: editSuccess,
            editError: editError
        )
    }
}

extension EditCommentViewModel {
    struct Input {
        let editTap: ControlEvent<Void>
        let editText: ControlProperty<String>
    }
    
    struct Output {
        let content: Observable<String>
        let editValid: Observable<Bool>
        let editSuccess: Observable<Comment>
        let editError: Observable<LSLPAPIError>
    }
}
