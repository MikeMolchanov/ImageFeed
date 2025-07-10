//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Михаил on 30.01.2025.
//

import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}
final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private var currentCompletion: ((Result<String, Error>) -> Void)?
    
    private init() {}
    
    // Функция для получения OAuth токена
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        // Вызываем completion для предыдущего запроса
        currentCompletion?(.failure(NetworkError.requestCancelled))
        task?.cancel()
        lastCode = code
        currentCompletion = completion
        // 2. Создаем запрос
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                // Сохраняем токен
                OAuth2TokenStorage.shared.token = response.accessToken
                completion(.success(response.accessToken))
                
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken] Error: \(error), code: \(code)")
                completion(.failure(error))
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    // запрос токена
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        // 1. Создаем компоненты URL для безопасного формирования
            var components = URLComponents()
            components.scheme = "https"
            components.host = "unsplash.com"
            components.path = "/oauth/token"
            // 2. Безопасно добавляем параметры
            components.queryItems = [
                URLQueryItem(name: "client_id", value: Constants.accessKey),
                URLQueryItem(name: "client_secret", value: Constants.secretKey),
                URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ]
        // 3. Проверяем валидность URL
            guard let url = components.url else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}



