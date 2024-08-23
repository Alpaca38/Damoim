//
//  LocationViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/22/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast

final class LocationViewController: BaseViewController {
    private let locationTextField = {
        let view = UITextField()
        view.leftViewMode = .always
        view.placeholder = l10nKey.placeholderLocation.rawValue.localized
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "map")?.withTintColor(.main, renderingMode: .alwaysOriginal)
        imageView.image = image
        view.leftView = imageView
        view.borderStyle = .roundedRect
        return view
    }()
    
    private let tableView = {
        let view = UITableView()
        view.backgroundColor = .background
        view.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.identifier)
        return view
    }()
    
    private let viewModel: LocationViewModel
    
    init(viewModel: LocationViewModel) {
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
        view.addSubview(locationTextField)
        view.addSubview(tableView)
        
        locationTextField.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(locationTextField.snp.bottom).offset(20)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

private extension LocationViewController {
    func setNavi() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = l10nKey.navigationTitleLocation.rawValue.localized
    }
    
    func bind() {
        let locationData = PublishRelay<[LocalSearchItem]>()
        let input = LocationViewModel.Input(
            text: locationTextField.rx.text.orEmpty
        )
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            locationData
                .bind(to: tableView.rx.items(cellIdentifier: LocationTableViewCell.identifier, cellType: LocationTableViewCell.self)) { row, element, cell in
                    cell.configure(data: element)
                }
            
            output.result
                .drive(with: self) { owner, result in
                    switch result {
                    case .success(let success):
                        locationData.accept(success.items)
                    case .failure(let error):
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            tableView.rx.modelSelected(LocalSearchItem.self)
                .bind(with: self) { owner, location in
                    let vm = CategoryViewModel(location: location.roadAddress)
                    let vc = CategoryViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
        }
    }
}
