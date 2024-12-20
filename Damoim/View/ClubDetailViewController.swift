//
//  ClubDetailViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast
import iamport_ios

final class ClubDetailViewController: NetworkViewController {
    private let menuButton = {
        let view = UIBarButtonItem(image: UIImage(systemName: "ellipsis"))
        view.tintColor = .black
        return view
    }()
    
    private lazy var contentView = {
        let view = UIView()
        [photoImageView, titleView, profileImageView, profileLabel, titleLabel, scheduleSummaryLabel, contentLabel, headCountLabel, moneyLabel, timeLabel, locationLabel, commentView].forEach {
            view.addSubview($0)
        }
        view.backgroundColor = .background
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
        view.clipsToBounds = true
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let titleView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let profileTapGesture = UITapGestureRecognizer()
    
    private lazy var profileImageView = {
        let view = ProfileImageView(cornerRadius: 20)
        view.addGestureRecognizer(profileTapGesture)
        view.isUserInteractionEnabled = true
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
        view.textAlignment = .left
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

    private let commentTapGesture = UITapGestureRecognizer()
    
    private lazy var commentView = {
        let view = UIView()
        view.addGestureRecognizer(commentTapGesture)
        view.isUserInteractionEnabled = true
        view.addSubview(commentImageView)
        view.addSubview(commentLabel)
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
    
    private let commentLabel = {
        let view = UILabel()
        view.text = l10nKey.placeholderComment.rawValue.localized
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    private lazy var buttonView = {
        let view = UIView()
        view.addSubview(heartButton)
        view.addSubview(joinButton)
        view.backgroundColor = .background
        self.view.addSubview(view)
        return view
    }()
    
    private let heartButton = {
        let view = UIButton()
        view.tintColor = .main
        return view
    }()
    
    private let joinButton = {
        let view = UIButton()
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let viewModel: ClubDetailViewModel
    
    init(viewModel: ClubDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavi()
        bind()
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
        
        commentLabel.snp.makeConstraints {
            $0.leading.equalTo(commentImageView.snp.trailing).offset(10)
            $0.height.equalTo(40)
            $0.centerY.equalToSuperview()
        }
    }
}

private extension ClubDetailViewController {
    func setNavi() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = menuButton
    }
    
    func bind() {
        let deleteTap = PublishRelay<String>()
        let paymentResponse = PublishSubject<IamportResponse?>()
        
        let input = ClubDetailViewModel.Input(
            joinTap: joinButton.rx.tap,
            likeTap: heartButton.rx.tap,
            deleteTap: deleteTap,
            paymentResponse: paymentResponse
        )
        
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.post
                .bind(with: self) { owner, post in
                    owner.profileLabel.text = post.creator.nick
                    owner.titleLabel.text = post.title
                    owner.scheduleSummaryLabel.text = post.descriptionLabel
                    owner.contentLabel.text = post.content
                    owner.headCountLabel.text = post.headCountLabel
                    owner.moneyLabel.text = String(post.price ?? 0).toCurrency
                    owner.timeLabel.text = post.content2
                    owner.locationLabel.text = post.content1
                }
            
            output.photoImageData
                .bind(with: self) { owner, data in
                    owner.photoImageView.image = UIImage(data: data)
                }
            
            output.profileImageData
                .bind(with: self) { owner, data in
                    owner.profileImageView.image = UIImage(data: data)
                }
            
            output.errorSubject
                .bind(with: self) { owner, error in
                    owner.view.makeToast(error.localizedDescription)
                }
            
            output.errorRelay
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            output.isMine
                .bind(with: self) { owner, value in
                    owner.joinButton.isEnabled = !value
                }
            
            output.isJoin
                .bind(with: self) { owner, value in
                    let joinBackgroundColor = value ? UIColor.lightGray : UIColor.main
                    owner.joinButton.backgroundColor = joinBackgroundColor
                    
                    let joinTitle = value ? l10nKey.buttonParticipating.rawValue.localized : l10nKey.buttonJoin.rawValue.localized
                    owner.joinButton.setTitle(joinTitle, for: .normal)
                }
            
            output.isLike
                .bind(with: self) { owner, value in
                    let likeButtonImage = value ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                    owner.heartButton.setImage(likeButtonImage, for: .normal)
                }
            
            commentTapGesture.rx.event
                .withLatestFrom(output.post)
                .bind(with: self) { owner, post in
                    let vm = CommentViewModel(postId: post.post_id)
                    let vc = CommentViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            
            profileTapGesture.rx.event
                .withLatestFrom(output.post)
                .bind(with: self) { owner, post in
                    let vm = ProfileViewModel(userId: post.creator.user_id)
                    let vc = ProfileViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            
            menuButton.rx.tap
                .withLatestFrom(output.post)
                .bind(with: self) { owner, value in
                    if value.creator.user_id == UserDefaultsManager.user_id {
                        owner.showActionSheet {
                            deleteTap.accept(value.post_id)
                        }
                    } else {
                        owner.view.makeToast(l10nKey.toastCannotEdit.rawValue.localized)
                    }
                }
            
            output.deleteSuccess
                .bind { _ in
                    SceneManager.shared.setScene(viewController: TabBarController())
                }
            
            output.deleteError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            output.paymentSubject
                .bind(with: self) { owner, payment in
                    Iamport.shared.payment(navController: owner.navigationController!, userCode: "imp57573124", payment: payment) { iamportResponse in
                        paymentResponse.onNext(iamportResponse)
                        print(String(describing: iamportResponse))
                    }
                }
            
            output.paymentSuccess
                .bind(with: self) { owner, _ in
                    owner.showAlert(title: "결제에 성공하였습니다!", message: nil, buttonTitle: "OK") {
                        SceneManager.shared.setScene(viewController: TabBarController())
                    }
                }
            
            output.paymentError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                        owner.showAlert(title: "결제에 실패하였습니다", message: "결제에 실패하여 초기 화면으로 이동합니다.", buttonTitle: "OK") {
                            SceneManager.shared.setScene(viewController: TabBarController())
                        }
                    }
                }
        }
        
        if let commentImageData = UserDefaultsManager.profileImageData {
            commentImageView.image = UIImage(data: commentImageData)
        }
    }
}

private extension ClubDetailViewController {
    func showActionSheet(deleteTap: @escaping() -> Void) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteButton = UIAlertAction(title: l10nKey.alertPostDelete.rawValue.localized, style: .destructive) { _ in
            // 포스트 삭제
            deleteTap()
        }
        
        let cancel = UIAlertAction(title: l10nKey.alertCancel.rawValue.localized, style: .cancel)
        
        alert.addAction(deleteButton)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}
