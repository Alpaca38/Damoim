//
//  ClubViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ClubViewModel: ViewModel {
    private let dummyData = [
        
        Post(post_id: "1", product_id: "1", title: "", content: "", content1: "", content2: "", content3: "", content4: "", content5: "", createdAt: "", creator: Creator(user_id: "", nick: "", profileImage: nil), files: [], likes: [], likes2: [], hashTags: [], comments: []),
        Post(post_id: "2", product_id: "1", title: "", content: "", content1: "", content2: "", content3: "", content4: "", content5: "", createdAt: "", creator: Creator(user_id: "", nick: "", profileImage: nil), files: [], likes: [], likes2: [], hashTags: [], comments: []),
        Post(post_id: "3", product_id: "2", title: "", content: "", content1: "", content2: "", content3: "", content4: "", content5: "", createdAt: "", creator: Creator(user_id: "", nick: "", profileImage: nil), files: [], likes: [], likes2: [], hashTags: [], comments: []),
        Post(post_id: "4", product_id: "2", title: "", content: "", content1: "", content2: "", content3: "", content4: "", content5: "", createdAt: "", creator: Creator(user_id: "", nick: "", profileImage: nil), files: [], likes: [], likes2: [], hashTags: [], comments: []),
        Post(post_id: "5", product_id: "3", title: "", content: "", content1: "", content2: "", content3: "", content4: "", content5: "", createdAt: "", creator: Creator(user_id: "", nick: "", profileImage: nil), files: [], likes: [], likes2: [], hashTags: [], comments: []),
        Post(post_id: "6", product_id: "3", title: "", content: "", content1: "", content2: "", content3: "", content4: "", content5: "", createdAt: "", creator: Creator(user_id: "", nick: "", profileImage: nil), files: [], likes: [], likes2: [], hashTags: [], comments: [])
    ]
    
    func transform(input: Input) -> Output {
        
        return Output(
           
        )
    }
}

extension ClubViewModel {
    struct Input {
        
    }
    
    struct Output {
        
    }
}
