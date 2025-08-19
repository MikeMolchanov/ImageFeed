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
        
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            fatalError("ImagesListViewController not found in storyboard")
        }
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_images_inactive"),
            selectedImage: UIImage(named: "tab_images_active")
        )
        imagesListViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_inactive"),
            selectedImage: UIImage(named: "tab_profile_active")
        )
        profileViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
