//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Михаил on 19.04.2025.
//

import Foundation

enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // 2
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data)) // 3
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))) // 4
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // 5
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // 6
            }
        })
        
        return task
    }
}

func decodeOAuthTokenResponse(data: Data) {
    do {
        let decoder = JSONDecoder()
        let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
        // Обработка успешно декодированного объекта response
        print("Декодированный объект: (response)")
    } catch {
        // Обработка ошибки декодирования
        print("Ошибка декодирования: (error.localizedDescription)")
    }
}
let code = WebViewViewController.code
OAuth2Service.shared.fetchOAuthToken(code: code, completion: <#T##(Result<String, Error>) -> Void#>)
