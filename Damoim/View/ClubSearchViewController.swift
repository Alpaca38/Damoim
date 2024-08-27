//
//  ClubSearchViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/20/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ClubSearchViewController: BasePostViewController {
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .background
        self.view.addSubview(view)
        return view
    }()
    
    private var dataSource: DataSource!
    private let viewModel: ClubSearchViewModel
    
    init(viewModel: ClubSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchController()
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
private extension ClubSearchViewController {
    func setSearchController() {
        searchController.searchBar.placeholder = l10nKey.placeholderSearch.rawValue.localized
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(0.33))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 0)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        return layout
    }
}

// MARK: DataSource
private extension ClubSearchViewController {
    func configureDataSource() {
        let registration = SearchCellRegistration { cell,indexPath,itemIdentifier in
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
private extension ClubSearchViewController {
    func bind() {
        let postSection = PublishRelay<[PostSection]>()
        
        let input = ClubSearchViewModel.Input(
            searchText: searchController.searchBar.rx.text.orEmpty,
            searchTap: searchController.searchBar.rx.searchButtonClicked
        )
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            postSection.bind(to: collectionView.rx.items(dataSource: dataSource))
            
            Observable.combineLatest(output.cardRelay, output.guessingRelay, output.strategyRelay)
                .bind { card, guessing, strategy in
                    var sectionData = [PostSection]()
                    if !card.isEmpty {
                        sectionData.append(contentsOf: [PostSection(model: l10nKey.sectionCard.rawValue.localized, items: card)])
                    }
                    
                    if !guessing.isEmpty {
                        sectionData.append(contentsOf: [PostSection(model: l10nKey.sectionGuessing.rawValue.localized, items: guessing)])
                    }
                    
                    if !strategy.isEmpty {
                        sectionData.append(contentsOf: [PostSection(model: l10nKey.sectionStrategy.rawValue.localized, items: strategy)])
                    }
                    
                    postSection.accept(sectionData)
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

extension ClubSearchViewController {
    typealias SearchCellRegistration = UICollectionView.CellRegistration<SearchCollectionViewCell, PostItem>
}
