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
    
    init(userId: String) {
        self.userId = userId
    }
    
    func transform(input: Input) -> Output {
        let profileImageData = BehaviorSubject<Data?>(value: nil)
        let profile = PublishSubject<Profile>()
        let profileError = PublishSubject<APIError>()
        
        let posts = BehaviorRelay<[PostItem]>(value: [])
        let postsError = PublishSubject<APIError>()
        
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
                case .failure(let failure):
                    profileError.onNext((failure))
                }
            }
        }
        
        NetworkManager.shared.fetchPostsByUser(userId: userId, next: nil) { result in
            switch result {
            case .success(let success):
                posts.accept(success.data.map({ $0.postItem }))
            case .failure(let failure):
                postsError.onNext(failure)
            }
        }
        
        return Output(
            profileImageData: profileImageData,
            profile: profile,
            profileError: profileError,
            posts: posts,
            postsError: postsError
        )
    }
}

extension ProfileViewModel {
    struct Input {
        
    }
    
    struct Output {
        let profileImageData: Observable<Data?>
        let profile: Observable<Profile>
        let profileError: Observable<APIError>
        let posts: BehaviorRelay<[PostItem]>
        let postsError: Observable<APIError>
    }
}
