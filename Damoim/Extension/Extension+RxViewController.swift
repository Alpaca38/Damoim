//
//  Extension+RxViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/20/24.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Bool> {
      let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
      return ControlEvent(events: source)
    }
}
