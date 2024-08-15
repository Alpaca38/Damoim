//
//  RoundTextField.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import UIKit

class RoundTextField: UITextField {
    init(placeholder: l10nKey) {
        super.init(frame: .zero)
        self.placeholder = placeholder.rawValue.localized
        borderStyle = .roundedRect
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
