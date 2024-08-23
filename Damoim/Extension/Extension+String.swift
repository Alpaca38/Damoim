//
//  Extension+String.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var toCurrency: String {
        guard let money = Int(self) else { return "" }
        return money.formatted(.currency(code: "KRW"))
    }
}

extension String {
    func asAttributedString(font: UIFont) -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        do {
            let attributedString = try NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            
            attributedString.addAttribute(
                .font,
                value: font,
                range: NSRange(location: 0, length: attributedString.length)
            )
            
            return attributedString
        } catch {
            return nil
        }
    }
}
