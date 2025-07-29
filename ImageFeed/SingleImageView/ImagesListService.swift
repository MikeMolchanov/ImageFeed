//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Михаил on 14.07.2025.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
}
struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    // Измененные CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"  // Явное указание snake_case
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
    
    struct UrlsResult: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
}
final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var token = OAuth2TokenStorage.shared.token
    private var lastLoadedPage: Int?
     var currentTask: URLSessionTask?
    private var nextPage = 1
    
    
    
    
    
    func fetchPhotosNextPage() {
        guard currentTask == nil else {
            print(" Загрузка уже идет, пропускаем новый запрос " )
            return
        }
        let pageToLoad = nextPage
        let perPage = 10
        guard let request = createRequest(page: pageToLoad, perPage: perPage) else {
            print ("Ошибка: неверный запрос")
            return
        }
        
        print("🔵 Начинаем загрузку страницы \(pageToLoad)")
        
        var currentTask = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            guard let self = self else {return}
            defer{self.currentTask = nil} // Сброс флага при завершении
            print("🔵 Задача завершена")
            
            if let error = error {
                print("Ошибка сети: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Ошибка: нет данных")
                return}
            
            // 3. Логирование ответа
            if let httpResponse = response as? HTTPURLResponse {
                print("🔵 Ответ сервера: статус \(httpResponse.statusCode)")
            }
            
            // 4. Печать первых 200 символов данных для проверки
            let rawDataString = String(data: data.prefix(200), encoding: .utf8) ?? "Неизвестные данные"
            print("🔵 Полученные данные (первые 200 символов):", rawDataString)
            
            do {
                let newPhotos = try self.parsePhotos(from: data) // Парсим JSON
                print("🟢 Успешно распаршено фотографий:", newPhotos.count)
                DispatchQueue.main.async {
                    self.nextPage += 1
                    self.photos.append(contentsOf: newPhotos)
                    print("🟣 Текущее количество фото:", self.photos.count)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                    object: self)
                    print("🔴 Уведомление отправлено")
                }
            } catch {
                print("Ошибка парсинга: \(error)")
            }
        }
        currentTask.resume()
        print("🟠 Задача запущена")
    }
    
    private func parsePhotos(from data: Data) throws -> [Photo] {
        do {
            // Декодируем как словарь с ключом "photos", если сервер так отвечает
            struct Response: Decodable {
                let photos: [PhotoResult]
            }
            let response = try JSONDecoder().decode(Response.self, from: data)
            return response.photos.map { Photo.from(photoResult: $0) }
        } catch {
            // Если структура другая - пробуем декодировать как массив напрямую
            return try JSONDecoder().decode([PhotoResult].self, from: data).map { Photo.from(photoResult: $0) }
        }
    }
    private func createRequest(page: Int, perPage: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Token is missing")
            return nil
        }
        
        var components = URLComponents(string: "https://api.unsplash.com/photos")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}



extension Photo {
    static func from(photoResult: PhotoResult) -> Photo {
        // 1. Преобразуем дату из String в Date
        let dateFormatter = ISO8601DateFormatter()
        
        // 2. Создаём CGSize из width/height
        let size = CGSize(width: photoResult.width, height: photoResult.height)
        
        
        let createdAtDate = dateFormatter.date(from: photoResult.createdAt)
            
        return Photo(id: photoResult.id,
                     size: size,
                     createdAt: createdAtDate,
                     welcomeDescription:photoResult.description,
                     thumbImageURL: photoResult.urls.thumb,
                     largeImageURL: photoResult.urls.full,
                     isLiked: photoResult.likedByUser)
    }
}
