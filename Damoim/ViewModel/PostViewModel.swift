//
//  PostViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/23/24.
//

import Foundation

final class PostViewModel: ViewModel {
    private let location: String
    private let category: String
    
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
        
    }
    
    struct Output {
        
    }
}
