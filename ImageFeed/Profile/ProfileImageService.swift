//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Михаил on 14.06.2025.
//

import Foundation

final class ProfileImageService {
    
    struct UserResult: Decodable {
        var profileImage: ProfileImage
        
        struct ProfileImage: Decodable {
            let small: String
        }
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    static let shared = ProfileImageService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    var avatarURL: String?
    
    private var currentTask: URLSessionTask?
    
    private init() {}
    
    func makeProfileImageRequest(token: String) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            assertionFailure("Failed to get OAuth token")
            return nil
        }
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        // Устанавливаем метод и заголовки
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        // 1. Отменить предыдущий запрос
        currentTask?.cancel()
        // Получаем токен
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.unauthorized))
            return
        }
        // 3. Создание запроса
        guard let request = makeProfileImageRequest(token: token) else {
            print("[ProfileImageService] Error: Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        // 4. Запуск задачи
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                defer {
                    self.currentTask = nil
                }
                switch result {
                case .success(let userResult):
                    let profileImageURL = userResult.profileImage.small
                    // СОХРАНЯЕМ ПРОФИЛЬ В СИНГЛТОНЕ
                    self.avatarURL = userResult.profileImage.small
                    print("[ProfileImageService] Avatar URL received: \(profileImageURL)")
                    // Вызываем completion
                    completion(.success(profileImageURL))
                    
                    NotificationCenter.default                                     // 1
                        .post(                                                     // 2
                            name: ProfileImageService.didChangeNotification,       // 3
                            object: self,                                          // 4
                            userInfo: ["URL": profileImageURL])                    // 5
                    
                case .failure(let error):
                    // Логирование ошибки получения аватара
                    print("[ProfileImageService.fetchProfileImageURL] Error: \(error), username: \(username)")
                    completion(.failure(error))
                }
            }
        }
        self.currentTask = task
        task.resume()
    }
}
