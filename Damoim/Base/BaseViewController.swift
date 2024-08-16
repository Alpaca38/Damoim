//
//  BaseViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.tintColor = .black
        configureLayout()
    }
    
    func configureLayout() {}
}
