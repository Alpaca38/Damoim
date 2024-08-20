//
//  LikeClubViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeClubViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let posts = BehaviorRelay<[PostItem]>(value: [])
        let fetchPostError = PublishSubject<APIError>()
        
        input.viewWillAppear
            .bind { _ in
                NetworkManager.shared.fetchLikedPost(next: nil, limit: nil) { result in
                    switch result {
                    case .success(let success):
                        posts.accept(success.data.map({ $0.postItem }))
                    case .failure(let failure):
                        fetchPostError.onNext(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            posts: posts,
            fetchPostsError: fetchPostError
        )
    }
}

extension LikeClubViewModel {
    struct Input {
        let viewWillAppear: ControlEvent<Bool>
    }
    
    struct Output {
        let posts: BehaviorRelay<[PostItem]>
        let fetchPostsError: PublishSubject<APIError>
    }
}
