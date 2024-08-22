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

final class LocationViewController: BaseViewController {
    private let locationTextField = {
        let view = UITextField()
        view.leftViewMode = .always
        view.placeholder = "장소를 입력해 주세요."
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
        navigationItem.title = "어디서 만날까요?"
    }
    
    func bind() {
        let input = LocationViewModel.Input(
            text: locationTextField.rx.text.orEmpty
        )
    }
}
