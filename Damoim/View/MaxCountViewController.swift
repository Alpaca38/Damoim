//
//  MaxCountViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/25/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MaxCountViewController: BaseViewController {
    private let titleLabel = {
        let view = UILabel()
        view.text = "최대 인원을 선택해주세요."
        view.font = .boldSystemFont(ofSize: 18)
        return view
    }()
    
    private let pickerView = UIPickerView()
    
    private let viewModel: MaxCountViewModel
    
    init(viewModel: MaxCountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func configureLayout() {
        view.addSubview(titleLabel)
        view.addSubview(pickerView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.leading.equalToSuperview().offset(20)
        }
        
        pickerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

private extension MaxCountViewController {
    func bind() {
        let input = MaxCountViewModel.Input(
            pickerSelect: pickerView.rx.modelSelected(String.self)
        )
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.items
                .bind(to: pickerView.rx.itemTitles) { row, element in
                    return element
                }
        }
    }
}
