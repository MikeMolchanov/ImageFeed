//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Михаил on 13.01.2025.
//

import UIKit

//final class OAuth2Service {
//    static let shared = OAuth2Service() // 1
//    private init() {}                   // 2
//    
//    func makeOAuthTokenRequest(code: String) -> URLRequest? {
//        guard let baseURL = URL(string: "https://unsplash.com") else {
//                return nil
//            }
//         guard let url = URL(
//             string: "/oauth/token"
//             + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
//             + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
//             + "&&redirect_uri=\(Constants.redirectURI)"
//             + "&&code=\(code)"
//             + "&&grant_type=authorization_code",
//             relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
//         )
//        else {
//             return nil
//         }
//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         return request
//     }
//    
//}

final class AuthViewController: UIViewController {
    @IBAction func loginButtonTapped(_ sender: UIButton) {
    }
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack") 
    }
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
        
        configureBackButton()
    }
    
}
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
