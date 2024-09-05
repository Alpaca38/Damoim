//
//  CategoryViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/23/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CategoryViewController: NetworkViewController {
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.backgroundColor = .background
        view.showsVerticalScrollIndicator = false
        view.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        self.view.addSubview(view)
        return view
    }()
    
    private let viewModel: CategoryViewModel
    
    init(viewModel: CategoryViewModel) {
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
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

// MARK: UI
private extension CategoryViewController {
    func setNavi() {
        navigationItem.title = l10nKey.navigationTitleCategory.rawValue.localized
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.15))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: Data Bind
private extension CategoryViewController {
    func bind() {
        let input = CategoryViewModel.Input(
            collectionViewTap: collectionView.rx.modelSelected(CategoryViewModel.Category.self)
        )
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.categoryData
                .bind(to: collectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.identifier, cellType: CategoryCollectionViewCell.self)) { item, element, cell in
                    cell.configure(data: element.rawValue)
                }
            
            output.collectionViewTap
                .bind(with: self) { owner, value in
                    let vm = PostViewModel(location: value.0, category: value.1)
                    let vc = PostViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
        }
    }
}
