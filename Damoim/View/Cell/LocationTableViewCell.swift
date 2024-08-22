//
//  LocationTableViewCell.swift
//  Damoim
//
//  Created by 조규연 on 8/22/24.
//

import UIKit
import SnapKit

final class LocationTableViewCell: BaseTableViewCell {
    private let titleLabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 15)
        view.numberOfLines = 0
        return view
    }()
    
    private let roadAddressLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .secondaryLabel
        view.numberOfLines = 0
        return view
    }()
    
    override func configureLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(roadAddressLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        roadAddressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func configure() {
        
    }
}
