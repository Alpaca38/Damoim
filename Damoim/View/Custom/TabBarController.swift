//
//  TabBarController.swift
//  Damoim
//
//  Created by 조규연 on 8/14/24.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setTaBarController()
    }
    
    func setTaBarController() {
        tabBar.tintColor = .main
        tabBar.unselectedItemTintColor = .gray
        
        let club = UINavigationController(rootViewController: ClubViewController())
        club.tabBarItem = UITabBarItem(title: l10nKey.tabClub.rawValue.localized, image: UIImage(systemName: "house.fill"), tag: 0)
        
        setViewControllers([club], animated: true)
    }
}
