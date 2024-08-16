//
//  ClubViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ClubViewModel: ViewModel {
    func transform(input: Input) -> Output {
        let cardRelay = BehaviorRelay<[PostItem]>(value: [])
        let guessingRelay = BehaviorRelay<[PostItem]>(value: [])
        let strategyRelay = BehaviorRelay<[PostItem]>(value: [])
        let errorRelay = PublishRelay<APIError>()
        
        
        NetworkManager.shared.fetchPosts(next: nil, product_id: "damoim_card") { result in
            switch result {
            case .success(let success):
                cardRelay.accept(success.data.map({ $0.postItem }))
            case .failure(let failure):
                errorRelay.accept(failure)
            }
        }
        
        NetworkManager.shared.fetchPosts(next: nil, product_id: "damoim_guessing") { result in
            switch result {
            case .success(let success):
                guessingRelay.accept(success.data.map({ $0.postItem }))
            case .failure(let failure):
                errorRelay.accept(failure)
            }
        }
        
        NetworkManager.shared.fetchPosts(next: nil, product_id: "damoim_strategy") { result in
            switch result {
            case .success(let success):
                strategyRelay.accept(success.data.map({ $0.postItem }))
            case .failure(let failure):
                errorRelay.accept(failure)
            }
        }
        
        return Output(
            cardRelay: cardRelay,
            guessingRelay: guessingRelay,
            strategyRelay: strategyRelay,
            errorRelay: errorRelay
        )
    }
}

extension ClubViewModel {
    struct Input {
        
    }
    
    struct Output {
        let cardRelay: BehaviorRelay<[PostItem]>
        let guessingRelay: BehaviorRelay<[PostItem]>
        let strategyRelay: BehaviorRelay<[PostItem]>
        let errorRelay: PublishRelay<APIError>
    }
}
