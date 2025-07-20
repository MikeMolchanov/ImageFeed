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
    
    func fetchPhotosNextPage() {
        
    }
}

//extension Photo {
//    static func from(photoResult: PhotoResult) -> Photo {
//        // 1. Преобразуем дату из String в Date
//        let dateFormatter = ISO8601DateFormatter()
//        
//        // 2. Создаём CGSize из width/height
//        let size = CGSize(width: photoResult.width, height: photoResult.height)
//        
//        let createdAtDate = photoResult.createdAt.flatMap { dateFormatter.date(from: $0)}
//        return Photo(id: photoResult.id,
//                     size: size,
//                     createdAt: createdAtDate,
//                     welcomeDescription:photoResult.description,
//                     thumbImageURL: photoResult.urls.thumb,
//                     largeImageURL: photoResult.urls.full,
//                     isLiked: photoResult.likedByUser)
//    }
//}
