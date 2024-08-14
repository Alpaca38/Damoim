//
//  SceneManager.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import UIKit

final class SceneManager {
    private init() { }
    
    static let shared = SceneManager()
    
    func setScene(viewController: UIViewController) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        
        sceneDelegate?.window?.rootViewController = viewController
        sceneDelegate?.window?.makeKeyAndVisible()
    }
    
    func setNaviScene(viewController: UIViewController) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        sceneDelegate?.window?.rootViewController = navigationController
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}
