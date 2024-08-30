//
//  ClubCollectionViewCell.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import UIKit
import SnapKit
import Kingfisher

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
        var config = UIButton.Configuration.tinted()
        config.background.backgroundColor = .main
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
        let view = UIButton(configuration: config)
        view.isEnabled = false
        return view
    }()
    
    private let titleLabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 15)
        return view
    }()
    
    private let descriptionLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .secondaryLabel
        return view
    }()
    
    private let profileImageView = ProfileImageView(cornerRadius: 10)
    
    private let profileLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .secondaryLabel
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
            $0.size.equalTo(82)
        }

        profileImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        
        labelStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.leading.equalTo(photoImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.height.equalTo(16)
        }
    }
    
    func configure(data: PostItem) {
        if let photoURL = data.files.first {
            NetworkManager.shared.fetchImage(parameter: photoURL) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let success):
                    photoImageView.image = UIImage(data: success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
        
        categoryLabel.setAttributedTitle(NSAttributedString(string: data.content5, attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .light), .foregroundColor: UIColor.white]), for: .normal)
        titleLabel.text = data.title
        descriptionLabel.text = data.descriptionLabel
        
        if let profileImageURL = data.creator.profileImage {
            NetworkManager.shared.fetchImage(parameter: profileImageURL) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let success):
                    profileImageView.image = UIImage(data: success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
        
        profileLabel.text = data.profileLabel
        
    }
}
