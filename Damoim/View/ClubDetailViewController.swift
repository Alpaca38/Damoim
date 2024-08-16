//
//  ClubDetailViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/16/24.
//

import UIKit
import SnapKit

final class ClubDetailViewController: BaseViewController {
    private lazy var contentView = {
        let view = UIView()
        [photoImageView, titleView, profileImageView, profileLabel, titleLabel, scheduleSummaryLabel, contentLabel, headCountLabel, moneyLabel, timeLabel, locationLabel, commentView].forEach {
            view.addSubview($0)
        }
        view.backgroundColor = .main
        return view
    }()
    
    private lazy var scrollView = {
        let view = UIScrollView()
        view.addSubview(contentView)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        self.view.addSubview(view)
        return view
    }()
    
    private let photoImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let titleView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let profileImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let profileLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .darkGray
        return view
    }()
    
    private let titleLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17)
        return view
    }()
    
    private let scheduleSummaryLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textColor = .secondaryLabel
        return view
    }()
    
    private let contentLabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 15)
        return view
    }()
    
    private let headCountLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.textColor = .darkGray
        return view
    }()
    
    private let moneyLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.textColor = .darkGray
        return view
    }()
    
    private let timeLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.textColor = .darkGray
        return view
    }()
    
    private let locationLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.textColor = .darkGray
        return view
    }()
    
    private lazy var commentView = {
        let view = UIView()
        view.addSubview(commentImageView)
        view.addSubview(commentTextField)
        view.addSubview(submitButton)
        view.backgroundColor = .white
        return view
    }()
    
    private let commentImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let commentTextField = {
        let view = UITextField()
        view.placeholder = l10nKey.placeholderComment.rawValue.localized
        return view
    }()
    
    private let submitButton = {
        let view = UIButton()
        view.setTitle(l10nKey.buttonSubmit.rawValue.localized, for: .normal)
        view.setTitleColor(.main, for: .normal)
        return view
    }()
    
    private lazy var buttonView = {
        let view = UIView()
        view.addSubview(heartButton)
        view.addSubview(joinButton)
        view.backgroundColor = .white
        self.view.addSubview(view)
        return view
    }()
    
    private let heartButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "heart"), for: .normal)
        return view
    }()
    
    private let joinButton = {
        let view = UIButton()
        view.setTitle(l10nKey.buttonJoin.rawValue.localized, for: .normal)
        view.backgroundColor = .main
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureLayout() {
        buttonView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(70)
        }
        
        heartButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.size.equalTo(50)
            $0.centerY.equalToSuperview()
        }
        
        joinButton.snp.makeConstraints {
            $0.leading.equalTo(heartButton.snp.trailing).offset(10)
            $0.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(buttonView.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        photoImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(view.frame.width / 2)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(photoImageView.snp.bottom).offset(-60)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(120)
        }
        
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(photoImageView).offset(-40)
            $0.size.equalTo(40)
        }
        
        profileLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(profileLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(40)
        }
        
        scheduleSummaryLabel.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(scheduleSummaryLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        headCountLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        moneyLabel.snp.makeConstraints {
            $0.top.equalTo(headCountLabel.snp.bottom).offset(10)
            $0.leading.equalTo(headCountLabel)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(moneyLabel.snp.bottom).offset(10)
            $0.leading.equalTo(headCountLabel)
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(10)
            $0.leading.equalTo(headCountLabel)
        }
        
        commentView.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(20)
            $0.height.equalTo(50)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        commentImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.size.equalTo(20)
            $0.centerY.equalToSuperview()
        }
        
        commentTextField.snp.makeConstraints {
            $0.leading.equalTo(commentImageView.snp.trailing).offset(10)
            $0.height.equalTo(40)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-40)
        }
        
        submitButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.leading.equalTo(commentTextField.snp.trailing)
            $0.centerY.equalToSuperview()
        }
    }
}
