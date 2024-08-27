//
//  SearchCollectionViewCell.swift
//  Damoim
//
//  Created by 조규연 on 8/27/24.
//

import UIKit
import SnapKit

final class SearchCollectionViewCell: BaseCollectionViewCell {
    private let imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override func configureLayout() {
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(data: PostItem) {
        if let photoURL = data.files.first {
            NetworkManager.shared.fetchImage(parameter: photoURL) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let success):
                    imageView.image = UIImage(data: success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
}
