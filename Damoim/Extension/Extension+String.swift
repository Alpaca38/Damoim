//
//  Extension+String.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var toCurrency: String {
        guard let money = Int(self) else { return "" }
        return money.formatted(.currency(code: "KRW"))
    }
}
