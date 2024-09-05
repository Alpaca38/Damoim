//
//  MyClubViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyClubViewController: NetworkViewController {
    private let refresher = UIRefreshControl()
    
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .background
        view.refreshControl = refresher
        self.view.addSubview(view)
        return view
    }()
    
    private let viewModel: MyClubViewModel
    private var dataSource: DataSource!
    
    init(viewModel: MyClubViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10nKey.tabMyClub.rawValue.localized
        configureDataSource()
        bind()
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: UI
private extension MyClubViewController {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(100))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: DataSource
private extension MyClubViewController {
    func configureDataSource() {
        let registration = ClubCellRegistration { cell, indexPath, itemIdentifier in
            cell.configure(data: itemIdentifier)
        }

        dataSource = DataSource(configureCell: { section, collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }
}

// MARK: Data Binding
private extension MyClubViewController {
    func bind() {
        let pagination = PublishSubject<Void>()
        let postSection = PublishRelay<[PostSection]>()
        
        let input = MyClubViewModel.Input(
            pagination: pagination,
            refresh: refresher.rx.controlEvent(.valueChanged)
        )
        
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            postSection
                .bind(to: collectionView.rx.items(dataSource: dataSource))
            
            output.posts
                .bind { postItem in
                    postSection.accept([PostSection(model: l10nKey.tabMyClub.rawValue.localized, items: postItem)])
                }
            
            output.fetchPostsError
                .share(replay: 1)
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            collectionView.rx.modelSelected(PostItem.self)
                .bind(with: self) { owner, postItem in
                    let vm = ClubDetailViewModel(postItem: postItem)
                    let vc = ClubDetailViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
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
            
            output.refreshComplete
                .bind(with: self) { owner, _ in
                    owner.refresher.endRefreshing()
                }
        }
    }
}
