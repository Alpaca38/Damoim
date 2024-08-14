//
//  Extension+Date.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import Foundation

extension Date {
    var localizedDate: String {
        let dateFormat = "dateFormat".localized
        return self.formatted(
            .dateTime
                .year(.twoDigits)
                .month(.twoDigits)
                .day(.twoDigits)
                .hour()
                .minute()
                .locale(Locale(identifier: dateFormat)))
        
    }
}
