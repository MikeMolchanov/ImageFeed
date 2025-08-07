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
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
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
        
        // Запуск процесса авторизации
        performSegue(withIdentifier: "ShowWebView", sender: nil)
        
    }
}
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let token):
                    OAuth2TokenStorage.shared.token = token
                    // 1. Закрываем WebView
                    vc.dismiss(animated: true) {
                        // 2. Уведомляем делегата о успешной аутентификации
                        self.delegate?.didAuthenticate(self)
                    }
                case .failure(let error):
                    self.showErrorAlert(message: error.localizedDescription)
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
