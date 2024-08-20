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
        
        let searchClubVM = ClubSearchViewModel()
        let searchClub = UINavigationController(rootViewController: ClubSearchViewController(viewModel: searchClubVM))
        searchClub.tabBarItem = UITabBarItem(title: l10nKey.tabSearch.rawValue.localized, image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let myClubVM = MyClubViewModel()
        let myClub = UINavigationController(rootViewController: MyClubViewController(viewModel: myClubVM))
        myClub.tabBarItem = UITabBarItem(title: l10nKey.tabMyClub.rawValue.localized, image: UIImage(systemName: "person.3.fill"), tag: 2)
        
        let likeClubVM = LikeClubViewModel()
        let likeClub = UINavigationController(rootViewController: LikeClubViewController(viewModel: likeClubVM))
        likeClub.tabBarItem = UITabBarItem(title: l10nKey.tabLike.rawValue.localized, image: UIImage(systemName: "heart.fill"), tag: 3)
        
        let profileVM = ProfileViewModel(userId: UserDefaultsManager.user_id)
        let profile = UINavigationController(rootViewController: ProfileViewController(viewModel: profileVM))
        profile.tabBarItem = UITabBarItem(title: l10nKey.tabProfile.rawValue.localized, image: UIImage(systemName: "person.fill"), tag: 4)
        
        setViewControllers([club, searchClub, myClub, likeClub, profile], animated: true)
    }
}
