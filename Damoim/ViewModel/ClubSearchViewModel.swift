//
//  ClubSearchViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ClubSearchViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let cardRelay = BehaviorRelay<[PostItem]>(value: [])
        let guessingRelay = BehaviorRelay<[PostItem]>(value: [])
        let strategyRelay = BehaviorRelay<[PostItem]>(value: [])
        let errorRelay = PublishRelay<LSLPAPIError>()
        
        input.searchTap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText)
            .distinctUntilChanged()
            .bind(with: self, onNext: { owner, searchText in
                NetworkManager.shared.searchHashTag(next: nil, limit: "100", product_id: "damoim_card", hashTag: searchText) { result in
                    switch result {
                    case .success(let success):
                        cardRelay.accept(success.data.map({ $0.postItem }))
                    case .failure(let failure):
                        errorRelay.accept(failure)
                    }
                }
                
                NetworkManager.shared.searchHashTag(next: nil, limit: "100", product_id: "damoim_guessing", hashTag: searchText) { result in
                    switch result {
                    case .success(let success):
                        guessingRelay.accept(success.data.map({ $0.postItem }))
                    case .failure(let failure):
                        errorRelay.accept(failure)
                    }
                }
                
                NetworkManager.shared.searchHashTag(next: nil, limit: "100", product_id: "damoim_strategy", hashTag: searchText) { result in
                    switch result {
                    case .success(let success):
                        strategyRelay.accept(success.data.map({ $0.postItem }))
                    case .failure(let failure):
                        errorRelay.accept(failure)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            cardRelay: cardRelay,
            guessingRelay: guessingRelay,
            strategyRelay: strategyRelay,
            errorRelay: errorRelay
        )
    }
    
    
}

extension ClubSearchViewModel {
    struct Input {
        let searchText: ControlProperty<String>
        let searchTap: ControlEvent<Void>
    }
    
    struct Output {
        let cardRelay: BehaviorRelay<[PostItem]>
        let guessingRelay: BehaviorRelay<[PostItem]>
        let strategyRelay: BehaviorRelay<[PostItem]>
        let errorRelay: PublishRelay<LSLPAPIError>
    }
}
