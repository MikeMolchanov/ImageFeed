//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Михаил on 01.06.2025.
//

import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    
    private init() {}
    
    struct ProfileResult: Codable {
        var firstName: String?
        var lastName: String?
        var username: String
        var bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
    }
    
    private var currentTask: URLSessionTask?
    private var currentToken: String?
    private var currentCompletion: ((Result<Profile, Error>) -> Void)?
    var profile: Profile?

    func makeProfileRequest(token: String) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            assertionFailure("Failed to get OAuth token")
            return nil
        }
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        // 4. Устанавливаем метод и заголовки
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        // 1. Проверка дублирующего запроса
        if let existingTask = currentTask {
            if currentToken == token {
                // Запрос с таким токеном уже выполняется
                print("[ProfileService] Warning: Request already in progress")
                completion(.failure(NetworkError.requestInProgress))
                return
            } else {
                // Отменяем предыдущий запрос с другим токеном
                print("[ProfileService] Cancelling previous request")
                existingTask.cancel()
                currentCompletion?(.failure(NetworkError.requestCancelled))
            }
        }
        // 2. Сохранение состояния
        currentToken = token
        currentCompletion = completion
        // 3. Создание запроса
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService] Error: Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            currentTask = nil
            currentToken = nil
            currentCompletion = nil
            return
        }
        // 4. Запуск задачи
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                // Обрабатываем результат
                switch result {
                case .success(let profileResult):
                    // Конвертируем ProfileResult → Profile
                    let profile = self.convertToProfile(profileResult: profileResult)
                    // Сохраняем профиль в синглтоне
                    self.profile = profile
                    print("[ProfileService] Profile successfully received")
                    self.currentCompletion?(.success(profile))
                    
                case .failure(let error):
                    print("[ProfileService.fetchProfile] Error: \(error), token: \(token)")
                    self.currentCompletion?(.failure(error))
                }
                
                // Всегда сбрасываем состояние
                self.resetState()
            }
        }
        currentTask = task
        task.resume()
    }
    private func resetState() {
        currentTask = nil
        currentToken = nil
        currentCompletion = nil
    }
    private func convertToProfile(profileResult: ProfileResult) -> Profile {
        // Создаем полное имя
        let fullName: String
        if let firstName = profileResult.firstName, let lastName = profileResult.lastName {
            fullName = "\(firstName) \(lastName)"
        } else if let firstName = profileResult.firstName {
            fullName = firstName
        } else if let lastName = profileResult.lastName {
            fullName = lastName
        } else {
            fullName = "No Name"
        }
        // Создаем логин
        let loginName = "@\(profileResult.username)"
        
        return Profile(
            username: profileResult.username,
            name: fullName,
            loginName: loginName,
            bio: profileResult.bio
        )
    }
}
