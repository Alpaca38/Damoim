//
//  BasePostViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/18/24.
//

import UIKit
import RxDataSources

class BasePostViewController: BaseViewController {
    typealias PostSection = AnimatableSectionModel<String, PostItem>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<PostSection>
    typealias ClubCellRegistration = UICollectionView.CellRegistration<ClubCollectionViewCell, PostItem>
}
