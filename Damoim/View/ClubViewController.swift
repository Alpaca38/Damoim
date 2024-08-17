//
//  ClubViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/15/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class ClubViewController: BaseViewController {
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .background
        self.view.addSubview(view)
        return view
    }()
    
    private var dataSource: DataSource!
    private let viewModel = ClubViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavi()
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
private extension ClubViewController {
    func setNavi() {
        navigationItem.title = l10nKey.navigationTitleClub.rawValue.localized
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.main
        ]
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(120))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
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
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        return layout
    }
}

// MARK: DataSource
private extension ClubViewController {
    func configureDataSource() {
        let registration = ClubCellRegistration { cell,indexPath,itemIdentifier in
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
    
    func bind() {
        let postSection = PublishRelay<[PostSection]>()
        let input = ClubViewModel.Input()
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            postSection
                .bind(to: collectionView.rx.items(dataSource: dataSource))
            
            Observable.combineLatest(output.cardRelay, output.guessingRelay, output.strategyRelay)
                .bind { card, guessing, strategy in
                    postSection.accept([
                        PostSection(model: l10nKey.sectionCard.rawValue.localized, items: card),
                        PostSection(model: l10nKey.sectionGuessing.rawValue.localized, items: guessing),
                        PostSection(model: l10nKey.sectionStrategy.rawValue.localized, items: strategy)
                    ])
                }
            
            output.errorRelay
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
        }
    }
}

private extension ClubViewController {
    typealias PostSection = AnimatableSectionModel<String, PostItem>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<PostSection>
    typealias ClubCellRegistration = UICollectionView.CellRegistration<ClubCollectionViewCell, PostItem>
}
