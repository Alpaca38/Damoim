//
//  MaxCountViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MaxCountViewModel: ViewModel {
    private var sendMaxCount: ((String) -> Void)?
    private let disposeBag = DisposeBag()
    
    init(sendMaxCount: ( (String) -> Void)? = nil) {
        self.sendMaxCount = sendMaxCount
    }
    
    func transform(input: Input) -> Output {
        let items = Observable.just(["2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"])
        
        input.pickerSelect
            .map { $0.first?.description ?? "" }
            .bind(with: self) { owner, value in
                owner.sendMaxCount?(value)
            }
            .disposed(by: disposeBag)
        
        return Output(
            items: items
        )
    }
    
    
}

extension MaxCountViewModel {
    struct Input {
        let pickerSelect: ControlEvent<[String]>
    }
    
    struct Output {
        let items: Observable<[String]>
    }
}
