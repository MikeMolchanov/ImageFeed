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
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token) // Переход будет внутри fetchProfile при успехе (исправление замечания по 11 спринту)
        } else {
            showAuthController()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        // Создание и настройка логотипа
        let logoImage = UIImage(named: "splash_screen_logo")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        // Добавление на экран
        view.addSubview(logoImageView)
        // Констрейнты для центрирования
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        checkAuthStatus()
    }
    private func checkAuthStatus() {
        if OAuth2TokenStorage.shared.token != nil {
            // Переход к основному интерфейсу
            switchToTabBarController()
        } else {
            // Показ экрана авторизации
            showAuthController()
        }
    }
    private func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("Failed to instantiate AuthViewController from storyboard")
        }
            
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        
        present(authVC, animated: true)
    }
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.switchToTabBarController() // ✅ Только здесь!
                // 2. Запускаем загрузку аватарки (НЕ ждем завершения!)
                if let username = profileService.profile?.username {
                    self.profileImageService.fetchProfileImageURL(username: username) { _ in
                        // Результат не важен на этом этапе
                    }
                }
                
            case .failure(let error):
                self.showErrorAlert(error: error) {
                    // Дополнительные действия после показа ошибки
                    self.fetchProfile(token) // повторная попытка
                }
            }
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
    private func showErrorAlert(error: Error, completion: (() -> Void)? = nil) {
        // 1. Формируем сообщение
        let message: String
        if let nsError = error as? NSError {
            message = "Ошибка \(nsError.code): \(nsError.localizedDescription)"
        } else {
            message = error.localizedDescription
        }
        
        // 2. Создаём алерт
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: "Не удалось загрузить профиль: \(message)",
            preferredStyle: .alert
        )
        // 3. Добавляем действия
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            completion?()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
            // Возврат на экран авторизации
            self.navigationController?.popToRootViewController(animated: true)
        })
        // 4. Показываем пользователю
        present(alert, animated: true, completion: nil)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        // Закрываем AuthViewController и переходим к основному интерфейсу
        vc.dismiss(animated: true){ [weak self] in
            guard let self = self else { return }
            guard let token = self.oauth2TokenStorage.token else {
                return
            }
            self.fetchProfile(token)
            self.switchToTabBarController()
            
        }
    }
}

