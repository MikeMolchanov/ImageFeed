//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Михаил on 30.01.2025.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    // запрос токена
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
        
        //task?.cancel() // 1. Отменяем предыдущую задачу (выдает ошибку из-за вызова до объявления)
        // 2. Создаем запрос
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request"])))
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверка на наличие ошибки сети
            if let error = error {
                print("[OAuth2Service] Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                print("[OAuth2Service] HTTP Error")
                completion(.failure(NetworkError.httpStatusCode(statusCode ?? 0)))
                return
            }
            // Проверка на наличие данных
            guard let data = data else {
                print("[OAuth2Service] Data Error: No data received from server")
                completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                // Парсинг JSON ответа
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["access_token"] as? String {
                    // сохранение токена
                    OAuth2TokenStorage.shared.token = accessToken
                    
                    completion(.success(accessToken))
                } else {
                    print("[OAuth2Service] response Error: Invalid response format")
                    completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                print("[OAuth2Service] Decoding Error ")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}



