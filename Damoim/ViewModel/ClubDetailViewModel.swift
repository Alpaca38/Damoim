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
import iamport_ios

final class ClubDetailViewModel: ViewModel {
    private let postItem: PostItem
    private let disposeBag = DisposeBag()
    
    init(postItem: PostItem) {
        self.postItem = postItem
    }
    
    func transform(input: Input) -> Output {
        let post = PublishSubject<Post>()
        let errorRelay = PublishRelay<LSLPAPIError>()
        
        let photoImageData = PublishSubject<Data>()
        let profileImageData = PublishSubject<Data>()
        let errorSubject = PublishSubject<AFError>()
        
        let deleteSuccess = PublishSubject<Void>()
        let deleteError = PublishSubject<LSLPAPIError>()
        
        let isMine = PublishSubject<Bool>()
        let isJoin = PublishSubject<Bool>()
        let isLike = PublishSubject<Bool>()
        
        let paymentSubject = PublishSubject<IamportPayment>()
        let paymentSuccess = PublishSubject<Payments>()
        let paymentError = PublishSubject<LSLPAPIError>()
        
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
                
                if post.likes2.contains(UserDefaultsManager.user_id) {
                    isLike.onNext(true)
                } else {
                    isLike.onNext(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.joinTap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(post)
            .bind(with: self, onNext: { owner, postData in
                if postData.likes.contains(UserDefaultsManager.user_id) {
                    NetworkManager.shared.join(postId: postData.post_id, like_status: false) { result in // 참여 해제
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
                    if let price = postData.price {
                        let payment = {
                            let payment = IamportPayment(
                                pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                                merchant_uid: "ios_\(APIKey.sesacKey)_\(Int(Date().timeIntervalSince1970))",
                                amount: "\(price)")
                            payment.pay_method = PayMethod.card.rawValue
                            payment.name = postData.title
                            payment.buyer_name = "조규연"
                            payment.app_scheme = "damoim"
                            return payment
                        }()
                        paymentSubject.onNext(payment)
                    } else {
                        NetworkManager.shared.join(postId: postData.post_id, like_status: true) { result in // 참여
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
                }
            })
            .disposed(by: disposeBag)
        
        input.likeTap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(post)
            .bind(with: self) { owner, postData in
                if postData.likes2.contains(UserDefaultsManager.user_id) {
                    NetworkManager.shared.like(postId: postData.post_id, like_status: false) { result in
                        switch result {
                        case .success(let success):
                            isLike.onNext(success)
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
                    NetworkManager.shared.like(postId: postData.post_id, like_status: true) { result in
                        switch result {
                        case .success(let success):
                            isLike.onNext(success)
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
            }
            .disposed(by: disposeBag)
        
        input.deleteTap
            .bind(with: self) { owner, postId in
                NetworkManager.shared.deletePost(postId: postId) { result in
                    switch result {
                    case .success(_):
                        deleteSuccess.onNext(())
                    case .failure(let failure):
                        deleteError.onNext(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.paymentResponse
            .bind(with: self) { owner, response in
                // 검증 API
                guard let response else { return }
                NetworkManager.shared.paymentsValidate(imp_uid: response.imp_uid!, post_id: owner.postItem.post_id) { result in
                    switch result {
                    case .success(let success):
                        paymentSuccess.onNext(success)
                        NetworkManager.shared.join(postId: owner.postItem.post_id, like_status: true) { result in
                            switch result {
                            case .success(let success):
                                isLike.onNext(success)
                            case .failure(let failure):
                                errorRelay.accept(failure)
                            }
                        }
                    case .failure(let failure):
                        paymentError.onNext(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            post: post,
            photoImageData: photoImageData,
            profileImageData: profileImageData,
            errorSubject: errorSubject,
            errorRelay: errorRelay,
            isMine: isMine,
            isJoin: isJoin,
            isLike: isLike,
            deleteSuccess: deleteSuccess,
            deleteError: deleteError,
            paymentSubject: paymentSubject,
            paymentSuccess: paymentSuccess,
            paymentError: paymentError
        )
    }
}

extension ClubDetailViewModel {
    struct Input {
        let joinTap: ControlEvent<Void>
        let likeTap: ControlEvent<Void>
        let deleteTap: PublishRelay<String>
        let paymentResponse: PublishSubject<IamportResponse?>
    }
    
    struct Output {
        let post: Observable<Post>
        let photoImageData: Observable<Data>
        let profileImageData: Observable<Data>
        let errorSubject: PublishSubject<AFError>
        let errorRelay: PublishRelay<LSLPAPIError>
        let isMine: Observable<Bool>
        let isJoin: Observable<Bool>
        let isLike: Observable<Bool>
        let deleteSuccess: PublishSubject<Void>
        let deleteError: PublishSubject<LSLPAPIError>
        let paymentSubject: PublishSubject<IamportPayment>
        let paymentSuccess: PublishSubject<Payments>
        let paymentError: PublishSubject<LSLPAPIError>
    }
}
