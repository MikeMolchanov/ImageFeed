//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Михаил on 07.12.2024.
//

import UIKit
import Kingfisher

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
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        let fontSize: CGFloat = 23.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return label
    }()
    private let loginNameLabel : UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        let fontSize: CGFloat = 13.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        return label
    }()
    private let descriptionLabel : UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
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
        
        setupViews()
        
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
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
