//
//  ViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = l10nKey.appName.rawValue.localized
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let emailTextField = RoundTextField(placeholder: .placeholderEmail)
    
    private let passwordTextField = {
        let textField = RoundTextField(placeholder: .placeholderPassword)
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(l10nKey.buttonSignIn.rawValue.localized, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let signButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(l10nKey.buttonSignUp.rawValue.localized, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
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
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signButton)
        
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
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        
        signButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(40)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
    }
}

private extension LoginViewController {
    func bind() {
        disposeBag.insert {
            signButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.navigationController?.pushViewController(SignUpViewController(), animated: true)
                }
        }
    }
}
