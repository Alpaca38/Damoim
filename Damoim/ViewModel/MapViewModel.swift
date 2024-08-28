//
//  MapVIewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/27/24.
//

import Foundation

final class MapViewModel: ViewModel {
    private let posts: [PostItem]
    
    init(posts: [PostItem]) {
        self.posts = posts
    }
    
    func transform(input: Input) -> Output {
        return Output(posts: posts)
    }
    
    
}

extension MapViewModel {
    struct Input {
        
    }
    
    struct Output {
        let posts: [PostItem]
    }
}
