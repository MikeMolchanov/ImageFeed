//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Михаил on 07.12.2024.
//

import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
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
        
        avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
        
        loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)

        
        guard let token = OAuth2TokenStorage.shared.token else {
            showError(NetworkError.unauthorized)
            return
        }
        // Загружаем профиль
        loadProfile(with: token)
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }

    
    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        let confirmAction = UIAlertAction(title: "Да", style: .default) { _ in
            // Удаляем токен
            OAuth2TokenStorage.shared.token = nil
            
            // Очищаем куки
            HTTPCookieStorage.shared.removeCookies(since: .distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach {
                    WKWebsiteDataStore.default().removeData(ofTypes: $0.dataTypes, for: [$0], completionHandler: {})
                }
            }
            
            // Вызываем logout и сброс сервисов
            ProfileLogoutService.shared.logout()
            
            // Переход на сплэш
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = SplashViewController()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }


    private func loadProfile(with token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.updateUI()
                    // После загрузки профиля загружаем аватар
                    self?.loadAvatar()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    private func loadAvatar() {
        guard let username = profileService.profile?.username else { return }
        
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            switch result {
            case .success:
                // Уведомление придет автоматически
                break
            case .failure(let error):
                print("Avatar loading error: \(error.localizedDescription)")
            }
        }
    }
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            // Установите placeholder, если URL недоступен
            avatarImageView.image = UIImage(named: "Stub")
            print("[ProfileViewController] Avatar URL is nil")
            return
        }
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Stub"))
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
    }
    private func updateUI() {
        guard let profile = profileService.profile else { return }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    private func showError(_ error: Error) {
            // Создаём сообщение об ошибке
            let message: String
            
            // Проверяем, является ли ошибка нашим кастомным типом
            if let networkError = error as? NetworkError {
                switch networkError {
                case .invalidRequest:
                    message = "Некорректный запрос"
                case .requestInProgress:
                    message = "Запрос уже выполняется"
                case .requestCancelled:
                    message = "Запрос отменён"
                case .httpStatusCode(let code):
                    message = "Ошибка сервера: \(code)"
                case .noData:
                    message = "Нет данных для отображения"
                case .decodingError:
                    message = "Ошибка обработки данных"
                case .urlRequestError(_):
                    message = "Ошибка запроса"
                case .urlSessionError:
                    message = "Ошибка задачи"
                case .invalidResponse:
                    message = "Ошибка ответа"
                case .unauthorized:
                    message = "Ошибка авторизации"
                case .profileImageNotFound:
                    message = "Ошибка аватарки"
                @unknown default:
                    message = "Неизвестная ошибка"
                }
            } else {
                // Для системных ошибок используем стандартное описание
                message = error.localizedDescription
            }
            
            let alert = UIAlertController(
                title: "Ошибка",
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            ))
            
            present(alert, animated: true, completion: nil)
        }
}
