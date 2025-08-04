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
    var isLiked: Bool
    let fullImageURL: String
}
struct PhotoResult: Codable {
    let id: String
    let createdAt: Date
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    
    let urls: UrlsResult
    
    struct UrlsResult: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
}
final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private var nextPage = 1
    
    func reset() {
        photos = []
        lastLoadedPage = nil
        currentTask?.cancel()
        currentTask = nil
        nextPage = 1
    }
    func fetchPhotosNextPage() {
        guard currentTask == nil else {
            print(" Загрузка уже идет, пропускаем новый запрос " )
            return
        }
        // Всегда сбрасываем на первую страницу при новой загрузке
        let pageToLoad = (lastLoadedPage == nil) ? 1 : (lastLoadedPage! + 1)
        let perPage = 10
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Ошибка: нет токена")
            return
        }
        
        guard let request = createRequest(page: pageToLoad, perPage: perPage, token: token) else {
            print("Ошибка: неверный запрос")
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
                    if pageToLoad == 1 {
                        self.photos = newPhotos
                    } else {
                        self.photos.append(contentsOf: newPhotos)
                    }
                    
                    self.lastLoadedPage = pageToLoad
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("Ошибка парсинга: \(error)")
            }
        }
        currentTask.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Ошибка: нет токена")
            completion(.failure(NetworkError.invalidToken))
            return
        }
        
        let method = isLike ? "POST" : "DELETE"
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            print("Ошибка: неверный URL для лайка")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked, 
                        fullImageURL: photo.fullImageURL
                    )
                    
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    private func createRequest(page: Int, perPage: Int, token: String) -> URLRequest? {
        var components = URLComponents(string: "https://api.unsplash.com/photos")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        guard let url = components.url else {
            print("Ошибка: неверный URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    private func parsePhotos(from data: Data) throws -> [Photo] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601 // Добавляем стратегию парсинга даты
        
        let photoResults = try decoder.decode([PhotoResult].self, from: data)
        
        return photoResults.map { photoResult in
            Photo(
                id: photoResult.id,
                size: CGSize(width: photoResult.width, height: photoResult.height),
                createdAt: photoResult.createdAt, // Теперь это автоматически преобразуется в Date
                welcomeDescription: photoResult.description,
                thumbImageURL: photoResult.urls.thumb,
                largeImageURL: photoResult.urls.full,
                isLiked: photoResult.likedByUser, 
                fullImageURL: photoResult.urls.full
            )
        }
    }
}
extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}

