//
//  MyClubViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyClubViewModel: ViewModel {
    func transform(input: Input) -> Output {
        let posts = BehaviorRelay<[PostItem]>(value: [])
        return Output()
    }
}

extension MyClubViewModel {
    struct Input {
        
    }
    
    struct Output {
        
    }
}
