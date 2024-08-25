//
//  Extension+UIViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String?, buttonTitle: String, buttonStyle: UIAlertAction.Style = .default, preferredStyle: UIAlertController.Style = .alert, isCancellable: Bool = false, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let button = UIAlertAction(title: buttonTitle, style: buttonStyle) { _ in
            completion()
        }
        let cancel = UIAlertAction(title: l10nKey.alertCancel.rawValue.localized, style: .cancel)
        
        if isCancellable {
            alert.addAction(button)
            alert.addAction(cancel)
        } else {
            alert.addAction(button)
        }
        present(alert, animated: true)
    }
}
