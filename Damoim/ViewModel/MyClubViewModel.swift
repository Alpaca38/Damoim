//
//  MyClubViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyClubViewModel: ViewModel {
    func transform(input: Input) -> Output {
        let posts = BehaviorRelay<[PostItem]>(value: [])
        let fetchPostError = PublishSubject<APIError>()
        
        NetworkManager.shared.fetchJoinedPost(next: nil, limit: nil) { result in
            switch result {
            case .success(let success):
                posts.accept(success.data.map({ $0.postItem }))
            case .failure(let failure):
                fetchPostError.onNext(failure)
            }
        }
        return Output(
            posts: posts,
            fetchPostsError: fetchPostError
        )
    }
}

extension MyClubViewModel {
    struct Input {
        
    }
    
    struct Output {
        let posts: BehaviorRelay<[PostItem]>
        let fetchPostsError: PublishSubject<APIError>
    }
}
