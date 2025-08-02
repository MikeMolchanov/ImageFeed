//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Михаил on 23.04.2025.
//

import Foundation

enum NetworkError: Error {  
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case requestCancelled
    case requestInProgress
    case invalidRequest
    case invalidResponse
    case noData
    case decodingError(Error)
    case unauthorized
    case profileImageNotFound
    case invalidToken
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            // Обрабатываем результат запроса
            switch result {
            case .success(let data):
                do {
                    // Пытаемся декодировать данные в тип T
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    // Если декодирование не удалось - возвращаем ошибку
                    // Логирование ошибки декодирования
                    let dataString = String(data: data, encoding: .utf8) ?? ""
                    print("[URLSession.objectTask] Decoding error: \(error), Data: \(dataString)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                // Если была ошибка сети - возвращаем ее
                completion(.failure(error))
            }
        }
        return task
    }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    // Логирование HTTP ошибки
                    let error = NetworkError.httpStatusCode(statusCode)
                    print("[URLSession.data] HTTP error: \(statusCode), URL: \(request.url?.absoluteString ?? "")")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                // Логирование ошибки запроса
                print("[URLSession.data] Request error: \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                // Логирование общей ошибки сессии
                print("[URLSession.data] Session error, URL: \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}
