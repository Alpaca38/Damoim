//
//  CategoryCollectionViewCell.swift
//  Damoim
//
//  Created by 조규연 on 8/23/24.
//

import UIKit
import SnapKit

final class CategoryCollectionViewCell: BaseCollectionViewCell {
    private let label = UILabel()
    
    override func configureLayout() {
        contentView.addSubview(label)
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        label.textAlignment = .center
        label.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(5)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.main.cgColor
    }
    
    func configure(data: String) {
        label.text = data
    }
}
