//
//  ProfileImageView.swift
//  Damoim
//
//  Created by 조규연 on 8/18/24.
//

import UIKit

final class ProfileImageView: UIImageView {
    init(cornerRadius: CGFloat) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        backgroundColor = .lightGray
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
