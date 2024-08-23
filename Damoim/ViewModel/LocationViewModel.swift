//
//  LocationViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/22/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LocationViewModel: ViewModel {
    func transform(input: Input) -> Output {
        let result = input.text
            .filter({ !$0.isEmpty })
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMap { query in
                NetworkManager.shared.localSearch(query: query, display: 5)
            }
            .asDriver(onErrorJustReturn: .failure(.serverError))
        
        return Output(
            result: result
        )
    }
}

extension LocationViewModel {
    struct Input {
        let text: ControlProperty<String>
    }
    
    struct Output {
        let result: Driver<Result<LocalSearch, NaverSearchAPIError>>
    }
}
