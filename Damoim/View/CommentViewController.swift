//
//  CommentViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast

final class CommentViewController: BaseViewController {
    private let emptyLabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        view.text = l10nKey.labelEmptyComment.rawValue.localized
        return view
    }()
    
    private lazy var commentView = {
        let view = UIView()
        view.addSubview(profileImageView)
        view.addSubview(commentTextField)
        view.addSubview(sendButton)
        view.backgroundColor = .white
        return view
    }()
    
    private let profileImageView = ProfileImageView(cornerRadius: 15)
    
    private let commentTextField = {
        let view = UITextField()
        view.placeholder = l10nKey.placeholderComment.rawValue.localized
        return view
    }()
    
    private let sendButton = {
        let view = UIButton()
        view.setAttributedTitle(NSAttributedString(string: l10nKey.buttonSubmit.rawValue.localized,
                                                   attributes: [
                                                    .font: UIFont.systemFont(ofSize: 14),
                                                    .foregroundColor: UIColor.lightGray
                                                   ]), for: .normal)
        return view
    }()
    
    private let tableView = {
        let view = UITableView()
        view.backgroundColor = .background
        view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        return view
    }()
    
    private let viewModel: CommentViewModel
    
    init(viewModel: CommentViewModel) {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func configureLayout() {
        view.addSubview(commentView)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
        }
        
        commentTextField.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(44)
            $0.trailing.equalToSuperview().offset(-50)
        }
        
        sendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        commentView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        tableView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(commentView.snp.top)
        }
    }
}

private extension CommentViewController {
    func setNavi() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = l10nKey.navigationTitleComment.rawValue.localized
    }
    
    func bind() {
        let editTap = PublishRelay<Comment>()
        let deleteTap = PublishRelay<String>()
        
        let input = CommentViewModel.Input(
            sendTap: sendButton.rx.tap,
            commentText: commentTextField.rx.text,
            editTap: editTap,
            deleteTap: deleteTap
        )
        
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.comments
                .bind(to: tableView.rx.items(cellIdentifier: CommentTableViewCell.identifier, cellType: CommentTableViewCell.self)) { row, element, cell in
                    cell.configure(data: element)
                    cell.menuButton.rx.tap
                        .bind(with: self) { owner, _ in
                            if element.creator.user_id == UserDefaultsManager.user_id {
                                owner.showActionSheet {
                                    editTap.accept(element)
                                } deleteTap: {
                                    deleteTap.accept(element.comment_id)
                                }
                            } else {
                                owner.view.makeToast("다른 사용자의 댓글은 수정할 수 없습니다.")
                            }
                        }
                        .disposed(by: cell.disposeBag)
                }
            
            tableView.rx.itemSelected
                .bind(with: self) { owner, _ in
                    owner.view.endEditing(true)
                }
            
            output.isEmpty
                .bind(with: self) { owner, isEmpty in
                    owner.emptyLabel.isHidden = !isEmpty
                    owner.tableView.isHidden = isEmpty
                }
            
            output.sendValid
                .bind(with: self) { owner, isValid in
                    if isValid {
                        owner.sendButton.setAttributedTitle(
                            NSAttributedString(
                                string: l10nKey.buttonSubmit.rawValue.localized,
                                attributes: [
                                    .font: UIFont.systemFont(ofSize: 14),
                                    .foregroundColor: UIColor.main
                                ]), for: .normal)
                    } else {
                        owner.sendButton.setAttributedTitle(
                            NSAttributedString(
                                string: l10nKey.buttonSubmit.rawValue.localized,
                                attributes: [
                                    .font: UIFont.systemFont(ofSize: 14),
                                    .foregroundColor: UIColor.lightGray
                                ]), for: .normal)
                    }
                    
                    owner.sendButton.isEnabled = isValid
                }
            
            output.fetchPostError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            output.createCommentError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            output.edit
                .bind(with: self) { owner, value in
                    let vm = EditCommentViewModel(postId: value.0, comment: value.1)
                    let vc = EditCommentViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            
            output.deleteCommentError
                .bind(with: self) { owner, error in
                    if error == .refreshTokenExpired {
                        SceneManager.shared.setNaviScene(viewController: LoginViewController())
                    } else {
                        owner.view.makeToast(error.rawValue)
                    }
                }
        }
        
        if let profileImageData = UserDefaultsManager.profileImageData {
            profileImageView.image = UIImage(data: profileImageData)
        }
    }
}

private extension CommentViewController {
    func showActionSheet(editTap: @escaping () -> Void, deleteTap: @escaping() -> Void) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editButton = UIAlertAction(title: "댓글 수정", style: .default) { _ in
            // postid랑 commentid 댓글 수정화면으로 넘기면서 화면 전환
            editTap()
        }
        
        let deleteButton = UIAlertAction(title: "댓글 삭제", style: .destructive) { _ in
            // 댓글 삭제
            deleteTap()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(editButton)
        alert.addAction(deleteButton)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}
