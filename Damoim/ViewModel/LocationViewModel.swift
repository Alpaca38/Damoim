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
        return Output()
    }
}

extension LocationViewModel {
    struct Input {
        let text: ControlProperty<String>
    }
    
    struct Output {
        
    }
}
