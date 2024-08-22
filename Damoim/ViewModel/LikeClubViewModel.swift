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
        let refreshComplete = PublishSubject<Void>()
        
        var postsData: [PostItem] = []
        let nextCursor = BehaviorSubject(value: "")
        
        NetworkManager.shared.fetchLikedPost(next: nil, limit: "7") { result in
            switch result {
            case .success(let success):
                postsData.removeAll()
                postsData.append(contentsOf: success.data.map({ $0.postItem }))
                nextCursor.onNext(success.next_cursor)
                posts.accept(postsData)
            case .failure(let failure):
                fetchPostError.onNext(failure)
            }
        }
        
        input.pagination
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(nextCursor)
            .distinctUntilChanged()
            .filter({ $0 != "0" })
            .bind(with: self) { owner, next in
                NetworkManager.shared.fetchJoinedPost(next: next, limit: nil) { result in
                    switch result {
                    case .success(let success):
                        postsData.append(contentsOf: success.data.map({ $0.postItem }))
                        nextCursor.onNext(success.next_cursor)
                        posts.accept(postsData)
                    case .failure(let failure):
                        fetchPostError.onNext(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.refresh
            .bind { _ in
                NetworkManager.shared.fetchLikedPost(next: nil, limit: "7") { result in
                    switch result {
                    case .success(let success):
                        postsData.removeAll()
                        postsData.append(contentsOf: success.data.map({ $0.postItem }))
                        nextCursor.onNext(success.next_cursor)
                        posts.accept(postsData)
                    case .failure(let failure):
                        fetchPostError.onNext(failure)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        refreshComplete.onNext(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            posts: posts,
            fetchPostsError: fetchPostError,
            refreshComplete: refreshComplete
        )
    }
}

extension LikeClubViewModel {
    struct Input {
        let pagination: PublishSubject<Void>
        let refresh: ControlEvent<Void>
    }
    
    struct Output {
        let posts: BehaviorRelay<[PostItem]>
        let fetchPostsError: PublishSubject<APIError>
        let refreshComplete: Observable<Void>
    }
}
