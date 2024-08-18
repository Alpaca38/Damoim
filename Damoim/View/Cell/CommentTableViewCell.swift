//
//  CommentTableViewCell.swift
//  Damoim
//
//  Created by 조규연 on 8/17/24.
//

import UIKit
import SnapKit

final class CommentTableViewCell: BaseTableViewCell {
    private let profileImageView = ProfileImageView(cornerRadius: 15)
    
    private let nickLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    private let contentLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.numberOfLines = 0
        view.textColor = .darkGray
        return view
    }()
    
    private let createDateLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 11)
        view.textColor = .secondaryLabel
        return view
    }()
    
    override func configureLayout() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nickLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(createDateLabel)
        
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(10)
            $0.size.equalTo(30)
        }
        
        nickLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.equalTo(nickLabel)
            $0.top.equalTo(nickLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        createDateLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nickLabel)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func configure(data: Comment) {
        if let profileURL = data.creator.profileImage {
            NetworkManager.shared.fetchImage(parameter: profileURL) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let data):
                    profileImageView.image = UIImage(data: data)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        nickLabel.text = data.creator.nick
        contentLabel.text = data.content
        createDateLabel.text = data.timeAgo
    }
}
