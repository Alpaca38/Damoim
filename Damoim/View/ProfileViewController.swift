//
//  ProfileViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class ProfileViewController: BasePostViewController {
    private let withdrawButton = {
        let view = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"))
        view.tintColor = .lightGray
        return view
    }()
    private let profileImageView = ProfileImageView(cornerRadius: 40)
    
    private let nickLabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 15)
        return view
    }()
    
    private lazy var followerStackView = {
        let view = UIStackView(arrangedSubviews: [followerLabel, followerCountLabel])
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        return view
    }()
    
    private lazy var followingStackView = {
        let view = UIStackView(arrangedSubviews: [followingLabel, followingCountLabel])
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        return view
    }()
    
    private lazy var feedStackView = {
        let view = UIStackView(arrangedSubviews: [feedLabel, feedCountLabel])
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        return view
    }()
    
    private lazy var profileStackView = {
        let view = UIStackView(arrangedSubviews: [followerStackView, followingStackView, feedStackView])
        view.axis = .horizontal
        view.distribution = .equalSpacing
        view.spacing = 20
        return view
    }()
    
    private let followerLabel = {
        let view = UILabel()
        view.text = l10nKey.follower.rawValue.localized
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    private let followingLabel = {
        let view = UILabel()
        view.text = l10nKey.following.rawValue.localized
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    private let feedLabel = {
        let view = UILabel()
        view.text = l10nKey.feed.rawValue.localized
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    private let followerCountLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        return view
    }()
    
    private let followingCountLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        return view
    }()
    
    private let feedCountLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        return view
    }()
    
    private let followButton = {
        var config = UIButton.Configuration.borderedTinted()
        config.background.backgroundColor = .main
        config.cornerStyle = .capsule
        let view = UIButton(configuration: config)
        view.setAttributedTitle(NSAttributedString(string: l10nKey.follow.rawValue.localized, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14)]), for: .normal)
        view.setAttributedTitle(NSAttributedString(string: l10nKey.following.rawValue.localized, attributes: [.foregroundColor: UIColor.main, .font: UIFont.systemFont(ofSize: 14)]), for: .selected)
        
        view.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.background.backgroundColor = button.isSelected ? .white : .main
            button.configuration = config
        }
        
        return view
    }()
    
    private let editProfileButton = {
        let view = UIButton()
        view.setTitle(l10nKey.buttonProfileEdit.rawValue.localized, for: .normal)
        view.backgroundColor = .main
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .background
        self.view.addSubview(view)
        return view
    }()
    
    private let viewModel: ProfileViewModel
    private var dataSource: DataSource!
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = withdrawButton
        configureDataSource()
        bind()
    }
    
    override func configureLayout() {
        view.addSubview(profileImageView)
        view.addSubview(nickLabel)
        view.addSubview(profileStackView)
        view.addSubview(followButton)
        view.addSubview(editProfileButton)
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(80)
        }
        
        nickLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(20)
            $0.leading.equalTo(profileImageView)
        }
        
        profileStackView.snp.makeConstraints {
            $0.top.equalTo(nickLabel.snp.bottom).offset(20)
            $0.leading.equalTo(nickLabel).offset(10)
        }
        
        followButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(profileStackView)
        }
        
        editProfileButton.snp.makeConstraints {
            $0.top.equalTo(profileStackView.snp.bottom).offset(20)
            $0.leading.equalTo(nickLabel)
            $0.trailing.equalTo(followButton)
            $0.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(editProfileButton.snp.bottom).offset(20)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: UI
private extension ProfileViewController {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(120))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 16
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: DataSource
private extension ProfileViewController {
    func configureDataSource() {
        let registration = ClubCellRegistration { cell, indexPath, itemIdentifier in
            cell.configure(data: itemIdentifier)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView,elementKind,indexPath in
            guard let self else { return }
            let sectionItem = dataSource.sectionModels[indexPath.section].model
            
            var content = UIListContentConfiguration.groupedHeader()
            
            content.text = sectionItem
            content.textProperties.font = .boldSystemFont(ofSize: 17)
            content.textProperties.color = .black
            
            supplementaryView.contentConfiguration = content
        }
        
        dataSource = DataSource(configureCell: { section, collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
            return cell
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        })
    }
}

// MARK: Data Binding
private extension ProfileViewController {
    func bind() {
        let followIsSelected = PublishSubject<Bool>()
        let profileSubject = PublishSubject<Profile>()
        let nicknameChange = PublishSubject<String>()
        let withdraw = PublishSubject<Void>()
        let pagination = PublishSubject<Void>()
        let postSection = PublishRelay<[PostSection]>()
        
        let input = ProfileViewModel.Input(
            followTap: followButton.rx.tap,
            followIsSelected: followIsSelected,
            profileSubject: profileSubject,
            withdraw: withdraw,
            pagination: pagination
        )
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.profileImageData
                .bind(with: self) { owner, data in
                    if let data {
                        owner.profileImageView.image = UIImage(data: data)
                    }
                }
            
            output.profile
                .bind(with: self) { owner, profile in
                    owner.nickLabel.text = profile.nick
                    owner.followerCountLabel.text = profile.followerCount
                    owner.followingCountLabel.text = profile.followingCount
                    owner.feedCountLabel.text = profile.feedCount
                }
            
            output.profileError
                .share(replay: 1)
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            postSection
                .bind(to: collectionView.rx.items(dataSource: dataSource))
            
            output.posts
                .bind { postItem in
                    postSection.accept([PostSection(model: l10nKey.feed.rawValue.localized, items: postItem)])
                }
            
            output.postsError
                .share(replay: 1)
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            output.isMine
                .bind(with: self) { owner, isMine in
                    owner.editProfileButton.isHidden = !isMine
                    owner.followButton.isHidden = isMine
                    owner.withdrawButton.isHidden = !isMine
                }
            
            collectionView.rx.modelSelected(PostItem.self)
                .bind(with: self) { owner, postItem in
                    let vm = ClubDetailViewModel(postItem: postItem)
                    let vc = ClubDetailViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            
            output.isFollowing
                .bind(with: self) { owner, isFollowing in
                    owner.followButton.isSelected = isFollowing
                    followIsSelected.onNext(isFollowing)
                }
            
            output.followSuccess
                .bind(with: self) { owner, message in
                    owner.view.makeToast(message)
                }
            
            output.unfollowSuccess
                .bind(with: self) { owner, message in
                    owner.view.makeToast(message)
                }
            
            output.followError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            output.unfollowError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            nicknameChange
                .bind(to: nickLabel.rx.text)
            
            editProfileButton.rx.tap
                .bind(with: self) { owner, _ in
                    let vm = EditProfileViewModel { profile in
                        profileSubject.onNext(profile)
                        owner.nickLabel.text = profile.nick
                    }
                    let vc = EditProfileViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            
            withdrawButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.showAlert(title: l10nKey.deleteAccount.rawValue.localized, message: l10nKey.deleteAccountMessage.rawValue.localized, buttonTitle: l10nKey.buttonOK.rawValue.localized, isCancellable: true) {
                        withdraw.onNext(())
                    }
                }
            
            output.withdrawError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            collectionView.rx.prefetchItems
                .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
                .bind(with: self) { owner, indexPaths in
                    indexPaths.forEach {
                        if output.posts.value.count - 1 == $0.item {
                            pagination.onNext(())
                        }
                    }
                }
        }
    }
}
