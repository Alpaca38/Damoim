//
//  PostViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/23/24.
//

import UIKit

final class PostViewController: BaseViewController {
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
    }
}

// MARK: UI
private extension PostViewController {
    func setNavi() {
        navigationItem.title = l10nKey.navigationTitlePost.rawValue.localized
    }
}
