//
//  EditCommentViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/21/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast

final class EditCommentViewController: NetworkViewController {
    private let editButton = {
        let view = UIBarButtonItem(title: l10nKey.buttonEdit.rawValue.localized)
        view.tintColor = .main
        return view
    }()
    
    private let commentTextView = {
        let view = UITextView()
        view.layer.cornerRadius = 10
        view.font = .systemFont(ofSize: 14)
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return view
    }()
    
    private let viewModel: EditCommentViewModel
    
    init(viewModel: EditCommentViewModel) {
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
        view.addSubview(commentTextView)
        
        commentTextView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(100)
        }
    }
}

private extension EditCommentViewController {
    func setNavi() {
        navigationItem.title = l10nKey.navigationTitleEditComment.rawValue.localized
        navigationItem.rightBarButtonItem = editButton
    }
    
    func bind() {
        let input = EditCommentViewModel.Input(
            editTap: editButton.rx.tap,
            editText: commentTextView.rx.text.orEmpty
        )
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.content
                .bind(to: commentTextView.rx.text)
            
            output.editValid
                .bind(with: self) { owner, value in
                    let color: UIColor = value ? .main : .gray
                    owner.editButton.tintColor = color
                    
                    owner.editButton.isEnabled = value
                }
            
            output.editSuccess
                .bind(with: self) { owner, _ in
                    owner.navigationController?.popViewController(animated: true)
                }
            
            output.editError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
        }
    }
}
