//
//  EditProfileViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/19/24.
//

import UIKit
import PhotosUI
import SnapKit
import RxSwift
import RxCocoa

final class EditProfileViewController: BaseViewController {
    private let saveButton = {
        let view = UIBarButtonItem(title: l10nKey.buttonSave.rawValue.localized)
        view.tintColor = .main
        return view
    }()
    
    private let profileTapGesture = UITapGestureRecognizer()
    
    private lazy var profileImageView = {
        let view = ProfileImageView(cornerRadius: 40)
        view.addGestureRecognizer(profileTapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
        
    
    private let nickLabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 15)
        view.text = l10nKey.labelNickname.rawValue.localized
        return view
    }()
    
    private let nickTextField = {
        let view = UITextField()
        view.placeholder = l10nKey.placeholderNickname.rawValue.localized
        view.borderStyle = .roundedRect
        return view
    }()
    
    private let viewModel: EditProfileViewModel
    
    init(viewModel: EditProfileViewModel) {
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
        view.addSubview(profileImageView)
        view.addSubview(nickLabel)
        view.addSubview(nickTextField)
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(80)
        }
        
        nickLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(40)
            $0.leading.equalTo(profileImageView)
        }
        
        nickTextField.snp.makeConstraints {
            $0.top.equalTo(nickLabel.snp.bottom).offset(20)
            $0.leading.equalTo(nickLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(44)
        }
    }
}

private extension EditProfileViewController {
    func setNavi() {
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func bind() {
        let input = EditProfileViewModel.Input(
            nickText: nickTextField.rx.text,
            saveTap: saveButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.profileImageData
                .bind(with: self) { owner, data in
                    if let data {
                        owner.profileImageView.image = UIImage(data: data)
                    }
                }
            
            output.nick
                .bind(to: nickTextField.rx.text)
            
            output.saveValid
                .bind(with: self) { owner, valid in
                    let color: UIColor = valid ? .main : .gray
                    owner.saveButton.tintColor = color
                    owner.saveButton.isEnabled = valid
                }
            
            profileTapGesture.rx.event
                .bind(with: self) { owner, _ in
                    var configuration = PHPickerConfiguration()
                    configuration.selectionLimit = 1
                    configuration.filter = .images
                    
                    let picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = self
                    owner.present(picker, animated: true)
                }
            
            output.editSuccess
                .bind(with: self) { owner, value in
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

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        results.first?.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                    self?.viewModel.imagePicked.onNext(image.pngData())
                }
            }
        })
    }
}
