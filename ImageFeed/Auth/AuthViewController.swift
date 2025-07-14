//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Михаил on 13.01.2025.
//

import UIKit
import ProgressHUD
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private var isAuthorizing = false  // 1. Объявляем флаг состояния
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Убедимся, что нет сохраненного токена при открытии экрана
        OAuth2TokenStorage.shared.clearToken()
        
        configureBackButton()
    }
    
    private func switchToMainInterface() {
        guard let window = UIApplication.shared.windows.first else { return }
        let tabBarVC = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarVC
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Oк", style: .default))
        present(alert, animated: true)
    }
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard !isAuthorizing else {return} // 2. Проверяем состояние
        isAuthorizing = true // 3. Блокируем повторные нажатия
        // Показываем индикатор загрузки сразу при нажатии
        UIBlockingProgressHUD.show()
        // Запуск процесса авторизации
        performSegue(withIdentifier: "showAuthenticationScreen", sender: nil)
        
    }
}
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            DispatchQueue.main.async {
            UIBlockingProgressHUD.dismiss()
                switch result {
                case.success(let token):
                    OAuth2TokenStorage.shared.token = token
                    self.delegate?.didAuthenticate(self) // Вызываем метод делегата!
                case .failure(let error):
                    // Обработка ошибки
                    self.showErrorAlert(message: "Не удалось войти в систему")
                }
                // Закрываем WebView после завершения запроса
                vc.dismiss(animated: true) {
                    // Всегда сбрасываем флаг блокировки
                    self.isAuthorizing = false
                }
            }
        }
    }    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true) // Закрываем AuthViewController
        self.isAuthorizing = false // сбрасываем флаг
        UIBlockingProgressHUD.dismiss() // скрываем индикатор загрузки
    }
}
