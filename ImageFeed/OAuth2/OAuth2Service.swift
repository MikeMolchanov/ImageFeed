//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Михаил on 30.01.2025.
//

import UIKit

enum AuthServiceError: Error {
    case invalidRequest
    case unauthorized
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
        
        currentCompletion?(.failure(NetworkError.requestCancelled))
        task?.cancel()
        lastCode = code
        currentCompletion = completion
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Проверка на ошибку сети
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверка статус-кода
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 401 {
                completion(.failure(AuthServiceError.unauthorized))
                return
            }
            
            // Обработка данных
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                OAuth2TokenStorage.shared.token = responseBody.accessToken
                completion(.success(responseBody.accessToken))
            } catch {
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



