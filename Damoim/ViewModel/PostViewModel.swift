//
//  PostViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostViewModel: ViewModel {
    private let location: String
    private let category: String
    private let disposeBag = DisposeBag()
    
    init(location: String, category: String) {
        self.location = location
        self.category = category
    }
    
    func transform(input: Input) -> Output {
        
        
        return Output()
    }
    
    
}

extension PostViewModel {
    struct Input {
        let imageData: Observable<Data?>
        let titleText: ControlProperty<String>
        let contentText: ControlProperty<String>
        let maxCount: PublishSubject<String>
    }
    
    struct Output {
        
    }
}
