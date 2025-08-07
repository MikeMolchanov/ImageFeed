//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Михаил on 08.07.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        // Первый таб — экран списка изображений
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )

        // Второй таб — экран профиля
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}


