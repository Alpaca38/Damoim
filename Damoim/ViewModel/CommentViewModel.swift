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
        
        let isEmpty = comments
            .map { $0.isEmpty }
        
        NetworkManager.shared.fetchSpecificPosts(postId: postId) { result in
            switch result {
            case .success(let success):
                comments.accept(success.comments)
            case .failure(let failure):
                fetchPostError.accept(failure)
            }
        }
        
        return Output(
            comments: comments,
            fetchPostError: fetchPostError,
            isEmpty: isEmpty
        )
    }
}

extension CommentViewModel {
    struct Input {
        let sendTap: ControlEvent<Void>
    }
    
    struct Output {
        let comments: BehaviorRelay<[Comment]>
        let fetchPostError: PublishRelay<APIError>
        let isEmpty: Observable<Bool>
    }
}
