//
//  SignUpViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class SignUpViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = l10nKey.buttonSignUp.rawValue.localized
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let emailTextField = RoundTextField(placeholder: .placeholderEmail)
    
    private let nicknameTextField = RoundTextField(placeholder: .placeholderNickname)
    
    private let passwordTextField = {
        let textField = RoundTextField(placeholder: .placeholderPassword)
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(l10nKey.buttonSignUp.rawValue.localized, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func configureLayout() {
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(nicknameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(40)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
    }
}

private extension SignUpViewController {
    func bind() {
        let input = SignUpViewModel.Input(
            signUpTap: signUpButton.rx.tap,
            email: emailTextField.rx.text.orEmpty,
            password: passwordTextField.rx.text.orEmpty,
            nickname: nicknameTextField.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.signUpResult
                .drive(with: self) { owner, result in
                    switch result {
                    case .success(let success):
                        owner.showAlert(title: success, message: nil, buttonTitle: l10nKey.buttonOK.rawValue.localized) {
                            SceneManager.shared.setNaviScene(viewController: LoginViewController())
                        }
                    case .failure(let error):
                        owner.view.makeToast(error.rawValue)
                    }
                }
            
            output.totalValid
                .bind(with: self) { owner, value in
                    let backgroundColor: UIColor = value ? .systemBlue : .gray
                    owner.signUpButton.backgroundColor = backgroundColor
                    owner.signUpButton.isEnabled = value
                }
        }
    }
}
