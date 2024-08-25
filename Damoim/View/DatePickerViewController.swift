//
//  DatePickerViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/25/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DatePickerViewController: BaseViewController {
    private let titleLabel = {
        let view = UILabel()
        view.text = "날짜 및 시간을 선택해주세요."
        view.font = .boldSystemFont(ofSize: 20)
        return view
    }()
    
    private let pickerView = UIDatePicker()
    
    private let viewModel: DatePickerViewModel
    
    init(viewModel: DatePickerViewModel) {
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
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

private extension DatePickerViewController {
    func bind() {
        let input = DatePickerViewModel.Input(
            dateSelect: pickerView.rx.date
        )
        _ = viewModel.transform(input: input)
    }
}
