//
//  PostViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/23/24.
//

import UIKit
import PhotosUI
import SnapKit
import RxSwift
import RxCocoa

final class PostViewController: BaseViewController {
    private let photoImage = {
        let view = UIImageView()
        view.image = UIImage(systemName: "camera.circle")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let photoTapGesture = UITapGestureRecognizer()
    
    private lazy var photoView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.addGestureRecognizer(photoTapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let titleTextField = {
        let view = UITextField()
        view.placeholder = l10nKey.placeholderTitle.rawValue.localized
        view.borderStyle = .roundedRect
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.leftViewMode = .always
        return view
    }()
    
    private let contentTextView = {
        let view = UITextView()
        view.layer.cornerRadius = 10
        view.font = .systemFont(ofSize: 14)
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.textColor = .lightGray
        view.text = l10nKey.placeholderContent.rawValue.localized
        return view
    }()
    
    private let maxCountButton = {
        let button = UIButton()
        button.setTitle(l10nKey.buttonMaxCount.rawValue.localized, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let deadlineButton = {
        let button = UIButton()
        button.setTitle(l10nKey.buttonDeadline.rawValue.localized, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let priceLabel = {
        let view = UILabel()
        view.text = l10nKey.labelFee.rawValue.localized
        return view
    }()
    
    private let priceTextField = {
        let view = UITextField()
        view.placeholder = l10nKey.placeholderFee.rawValue.localized
        view.keyboardType = .numberPad
        return view
    }()
    
    private lazy var contentView = {
        let view = UIView()
        view.addSubview(photoImage)
        view.addSubview(photoView)
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        view.addSubview(maxCountButton)
        view.addSubview(deadlineButton)
        view.addSubview(priceLabel)
        view.addSubview(priceTextField)
        return view
    }()
    
    private let scrollTapGesture = UITapGestureRecognizer()
    
    private lazy var scrollView = {
        let view = UIScrollView()
        view.addSubview(contentView)
        view.addGestureRecognizer(scrollTapGesture)
        return view
    }()
    
    private let createPostButton = {
        let button = UIButton()
        button.setTitle(l10nKey.buttonPost.rawValue.localized, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let viewModel: PostViewModel
    
    init(viewModel: PostViewModel) {
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
        view.addSubview(scrollView)
        view.addSubview(createPostButton)
        
        photoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(80)
        }
        
        photoImage.snp.makeConstraints {
            $0.center.equalTo(photoView)
            $0.size.equalTo(30)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(photoView.snp.bottom).offset(20)
            $0.leading.equalTo(photoView)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(44)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(titleTextField)
            $0.height.equalTo(200)
        }
        
        maxCountButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(contentTextView)
            $0.height.equalTo(44)
        }
        
        deadlineButton.snp.makeConstraints {
            $0.top.equalTo(maxCountButton.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(contentTextView)
            $0.height.equalTo(44)
        }
        
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(deadlineButton.snp.bottom).offset(20)
            $0.leading.equalTo(deadlineButton)
        }
        
        priceTextField.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalTo(contentTextView)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        createPostButton.snp.makeConstraints {
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-8)
            $0.horizontalEdges.equalTo(priceTextField)
            $0.height.equalTo(44)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(createPostButton.snp.top)
        }
        
    }
}

// MARK: UI
private extension PostViewController {
    func setNavi() {
        navigationItem.title = l10nKey.navigationTitlePost.rawValue.localized
    }
}

// MARK: Data bind
private extension PostViewController {
    func bind() {
        let maxCount = PublishSubject<String>()
        let input = PostViewModel.Input(
            imageData: photoView.rx.observe(UIImage.self, "image")
                .map({ $0?.pngData() })
                .share(replay: 1),
            titleText: titleTextField.rx.text.orEmpty,
            contentText: contentTextView.rx.text.orEmpty,
            maxCount: maxCount
        )
        
        let output = viewModel.transform(input: input)
        
        disposeBag.insert {
            contentTextView.rx.didBeginEditing
                .bind(with: self) { owner, _ in
                    if owner.contentTextView.textColor == .lightGray {
                        owner.contentTextView.text = nil
                        owner.contentTextView.textColor = .black
                    }
                }
            
            contentTextView.rx.didEndEditing
                .bind(with: self) { owner, _ in
                    if owner.contentTextView.text.isEmpty {
                        owner.contentTextView.text = l10nKey.placeholderContent.rawValue.localized
                        owner.contentTextView.textColor = .lightGray
                    }
                }
            
            scrollTapGesture.rx.event
                .bind(with: self) { owner, _ in
                    owner.view.endEditing(true)
                }
            
            photoTapGesture.rx.event
                .bind(with: self) { owner, _ in
                    var configuration = PHPickerConfiguration()
                    configuration.selectionLimit = 1
                    configuration.filter = .images
                    
                    let picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = self
                    owner.present(picker, animated: true)
                }
            
            maxCountButton.rx.tap
                .bind(with: self) { owner, _ in
                    let vm = MaxCountViewModel { value in
                        owner.maxCountButton.backgroundColor = .main
                        owner.maxCountButton.setTitle("최대 \(value)명", for: .normal)
                        maxCount.onNext(value)
                    }
                    let vc = MaxCountViewController(viewModel: vm)
                    vc.modalPresentationStyle = .pageSheet
                    
                    if let sheet = vc.sheetPresentationController {
                        sheet.detents = [.medium()]
                        sheet.prefersGrabberVisible = true
                    }
                    owner.present(vc, animated: true)
                }
        }
    }
}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        results.first?.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.photoView.image = image
                }
            }
        })
    }
}
