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
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width, height, color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description, urls
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
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
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
        
        var currentTask = URLSession.shared.dataTask(with: request) {[weak self] data, _, error in
            guard let self = self else {return}
            defer{self.currentTask = nil} // Сброс флага при завершении
            
            if let error = error {
                print("Ошибка сети: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Ошибка: нет данных")
                return}
            
            do {
                let newPhotos = try self.parsePhotos(from: data) // Парсим JSON
                DispatchQueue.main.async {
                    self.nextPage += 1
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                    object: self)
                }
            } catch {
                print("Ошибка парсинга: \(error)")
            }
        }
        currentTask.resume()
    }
    
    private func createRequest(page: Int, perPage: Int ) -> URLRequest? {
        let baseURL = "https://api.unsplash.com/photos"
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))]
        
        guard let url = components?.url else {
            print("Ошибка: неверный URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("695743 KLjJjKd0HAHZefLoKnLVZ4ZfoJSiksS-riusDQ7l-R8", forHTTPHeaderField: "Authorization") //найти свой ключ аккаунта Unsplash
        return request
    }
    private func parsePhotos(from data: Data) throws -> [Photo] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let photoResults = try decoder.decode([PhotoResult].self, from: data)
        
        // Конвертируем [PhotoResult] в [Photo]
        return photoResults.map { Photo.from(photoResult: $0) }
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
