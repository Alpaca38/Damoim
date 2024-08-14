//
//  ViewModel.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

protocol ViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
