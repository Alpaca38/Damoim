//
//  CategoryViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CategoryViewModel: ViewModel {
    private let location: String
    private let disposeBag = DisposeBag()
    
    init(location: String) {
        self.location = location
    }
    
    func transform(input: Input) -> Output {
        let categoryData = BehaviorSubject<[Category]>(value: Category.allCases)
        let collectionViewTap = PublishSubject<(String, Category)>()
        
        input.collectionViewTap
            .bind(with: self) { owner, category in
                collectionViewTap.onNext((owner.location, category))
            }
            .disposed(by: disposeBag)
        
        return Output(
            categoryData: categoryData,
            collectionViewTap: collectionViewTap
        )
    }
}

extension CategoryViewModel {
    struct Input {
        let collectionViewTap: ControlEvent<Category>
    }
    
    struct Output {
        let categoryData: Observable<[Category]>
        let collectionViewTap: Observable<(String, Category)>
    }
    
    enum Category: String, CaseIterable {
        case card = "카드 게임"
        case guessing = "추리 게임"
        case strategy = "전략 게임"
        
        var product_id: String {
            switch self {
            case .card:
                "damoim_card"
            case .guessing:
                "damoim_guessing"
            case .strategy:
                "damoim_strategy"
            }
        }
    }
}
