//
//  ProfileViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/18/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel: ViewModel {
    private let userId: String
    private let disposeBag = DisposeBag()
    
    init(userId: String) {
        self.userId = userId
    }
    
    func transform(input: Input) -> Output {
        let profileImageData = BehaviorSubject<Data?>(value: nil)
        let profile = PublishSubject<Profile>()
        let profileError = PublishSubject<APIError>()
        
        let posts = BehaviorRelay<[PostItem]>(value: [])
        let postsError = PublishSubject<APIError>()
        
        let isMine = BehaviorSubject<Bool>(value: true)
        let isFollowing = PublishSubject<Bool>()
        
        let followSuccess = PublishSubject<String>()
        let followError = PublishSubject<APIError>()
        let unfollowSuccess = PublishSubject<String>()
        let unfollowError = PublishSubject<APIError>()
        
        if userId == UserDefaultsManager.user_id {
            profileImageData.onNext(UserDefaultsManager.profileImageData)
            
            NetworkManager.shared.fetchMyProfile { result in
                switch result {
                case .success(let success):
                    profile.onNext(success)
                case .failure(let failure):
                    profileError.onNext(failure)
                }
            }
            
            isMine.onNext(true)
        } else {
            NetworkManager.shared.fetchOtherUserProfile(userId: userId) { result in
                switch result {
                case .success(let success):
                    profile.onNext(success)
                    if let profileURL = success.profileImage {
                        NetworkManager.shared.fetchImage(parameter: profileURL) { result in
                            switch result {
                            case .success(let success):
                                profileImageData.onNext(success)
                            case .failure(let failure):
                                print(failure)
                            }
                        }
                    }
                    // 팔로우 상태 확인
                    if success.followers.filter({ $0.user_id == UserDefaultsManager.user_id }).isEmpty {
                        isFollowing.onNext(false)
                    } else {
                        isFollowing.onNext(true)
                    }
                case .failure(let failure):
                    profileError.onNext((failure))
                }
            }
            isMine.onNext(false)
        }
        
        NetworkManager.shared.fetchPostsByUser(userId: userId, next: nil) { result in
            switch result {
            case .success(let success):
                posts.accept(success.data.map({ $0.postItem }))
            case .failure(let failure):
                postsError.onNext(failure)
            }
        }
        
        input.followTap
            .withLatestFrom(input.followIsSelected)
            .bind(with: self) { owner, isSelected in
                if isSelected {
                    NetworkManager.shared.unfollow(userId: owner.userId) { result in
                        switch result {
                        case .success(_):
                            unfollowSuccess.onNext(l10nKey.toastUnfollowSuccess.rawValue.localized)
                            isFollowing.onNext(false)
                        case .failure(let failure):
                            unfollowError.onNext(failure)
                        }
                    }
                } else {
                    NetworkManager.shared.follow(userId: owner.userId) { result in
                        switch result {
                        case .success(_):
                            followSuccess.onNext(l10nKey.toastFollowSuccess.rawValue.localized)
                            isFollowing.onNext(true)
                        case .failure(let failure):
                            followError.onNext(failure)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.profileSubject
            .bind(with: self) { owner, profile in
                if let imageURL = profile.profileImage {
                    NetworkManager.shared.fetchImage(parameter: imageURL) { result in
                        switch result {
                        case .success(let success):
                            profileImageData.onNext(success)
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            profileImageData: profileImageData,
            profile: profile,
            profileError: profileError,
            posts: posts,
            postsError: postsError,
            isMine: isMine,
            isFollowing: isFollowing,
            followSuccess: followSuccess,
            unfollowSuccess: unfollowSuccess,
            followError: followError,
            unfollowError: unfollowError
        )
    }
}

extension ProfileViewModel {
    struct Input {
        let followTap: ControlEvent<Void>
        let followIsSelected: PublishSubject<Bool>
        let profileSubject: PublishSubject<Profile>
    }
    
    struct Output {
        let profileImageData: Observable<Data?>
        let profile: Observable<Profile>
        let profileError: Observable<APIError>
        let posts: BehaviorRelay<[PostItem]>
        let postsError: Observable<APIError>
        let isMine: Observable<Bool>
        let isFollowing: Observable<Bool>
        let followSuccess: Observable<String>
        let unfollowSuccess: Observable<String>
        let followError: Observable<APIError>
        let unfollowError: Observable<APIError>
    }
}
