//
//  DatePickerViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DatePickerViewModel: ViewModel {
    private var sendDate: ((String) -> Void)?
    private let disposeBag = DisposeBag()
    
    init(sendDate: ( (String) -> Void)? = nil) {
        self.sendDate = sendDate
    }
    
    func transform(input: Input) -> Output {
        input.dateSelect
            .bind(with: self) { owner, date in
                owner.sendDate?(date.localizedDate)
            }
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    
}

extension DatePickerViewModel {
    struct Input {
        let dateSelect: ControlProperty<Date>
    }
    
    struct Output {
        
    }
}
