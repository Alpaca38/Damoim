//
//  ClubCollectionViewCell.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import UIKit
import SnapKit

final class ClubCollectionViewCell: BaseCollectionViewCell {
    private let photoImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let categoryLabel = {
        var config = UIButton.Configuration.gray()
        config.cornerStyle = .capsule
        config.attributedTitle = AttributedString(NSAttributedString(string: "등산", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)])) // dummy
        let view = UIButton(configuration: config)
        view.isEnabled = false
        return view
    }()
    
    private let titleLabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 15)
        view.text = "할리갈리 같이하실 분!!" // dummy
        return view
    }()
    
    private let descriptionLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .secondaryLabel
        view.text = "서초구·8.13(토) 오전 10:00" // dummy
        return view
    }()
    
    private let profileImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let profileLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .secondaryLabel
        view.text = "주철용 1명 참여" // dummy
        return view
    }()
    
    private lazy var profileStack = {
        let view = UIStackView(arrangedSubviews: [profileImageView, profileLabel])
        view.axis = .horizontal
        view.spacing = 2
        view.distribution = .equalSpacing
        return view
    }()
    
    private lazy var labelStack = {
        let view = UIStackView(arrangedSubviews: [categoryLabel, titleLabel, descriptionLabel, profileStack])
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
    }
    
    override func configureLayout() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(labelStack)
        
        photoImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(10)
            $0.size.equalTo(95)
        }

        profileImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        
        labelStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.leading.equalTo(photoImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
    
    func configure(data: Post) {
        
    }
}
