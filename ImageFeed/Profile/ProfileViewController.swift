//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Михаил on 07.12.2024.
//

import UIKit
import Kingfisher
import WebKit

// ProfileViewControllerProtocol.swift
protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func updateAvatar(url: URL)
    func showLogoutConfirmation()
    func showError(_ error: Error)
}

// ProfilePresenterProtocol.swift
protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}


final class ProfileViewController: UIViewController {
    
    var presenter: ProfilePresenterProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared
    private var profile: ProfileService.Profile?
    private let avatarImageView : UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "Photo")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 35
        view.image = image
        return view
    }()
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .ypWhite
        let fontSize: CGFloat = 23.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return label
    }()
    private let loginNameLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .ypGray
        let fontSize: CGFloat = 13.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        return label
    }()
    private let descriptionLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .ypWhite
        let fontSize: CGFloat = 13.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        return label
    }()
    private let logoutButton : UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(named: "Exit")
        button.setImage(buttonImage, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupViews()
        presenter?.viewDidLoad() // ВСЯ логика будет у презентера
    }

    

    
    @objc private func didTapLogoutButton() {
        presenter?.didTapLogout()
    }

    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    private func setupViews() {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }

}

extension ProfileViewController: ProfileViewControllerProtocol {
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        nameLabel.text = name
        loginNameLabel.text = loginName
        descriptionLabel.text = bio
    }

    func updateAvatar(url: URL) {
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "Stub"))
    }

    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Нет", style: .cancel)
        let confirm = UIAlertAction(title: "Да", style: .default) { _ in
            OAuth2TokenStorage.shared.token = nil
            HTTPCookieStorage.shared.removeCookies(since: .distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach {
                    WKWebsiteDataStore.default().removeData(ofTypes: $0.dataTypes, for: [$0], completionHandler: {})
                }
            }
            ProfileLogoutService.shared.logout()
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = SplashViewController()
            }
        }

        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true)
    }

    func showError(_ error: Error) {
        let message = (error as? NetworkError)?.localizedDescription ?? error.localizedDescription
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

