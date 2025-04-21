//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Михаил on 30.01.2025.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service() // 1
    private init() {}                   // 2
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            return nil
        }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
            + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
        )
        else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // Функция для получения OAuth токена
        func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
            guard let request = makeOAuthTokenRequest(code: code) else {
                completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request"])))
                return
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Проверка на наличие ошибок
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Проверка на наличие данных
                guard let data = data else {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }

                do {
                    // Парсинг JSON ответа
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let accessToken = json["access_token"] as? String {
                        completion(.success(accessToken))
                    } else {
                        completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()
        }
}
