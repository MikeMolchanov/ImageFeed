//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Михаил on 04.05.2025.
//

import UIKit
final class SplashViewController: UIViewController {
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")}
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        // Закрываем AuthViewController и переходим к основному интерфейсу
        vc.dismiss(animated: true){ [weak self] in
            self?.switchToTabBarController()
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
