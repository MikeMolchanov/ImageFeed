//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Михаил on 30.04.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // 1. Синглтон для доступа из любого места
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    // Создаем уникальный ключ для хранения
    private let serviceName = "ImageFeed"
    private let tokenKey = "tokenKey"
    
    var token: String? {
        get {
            // Получаем токен из Keychain
            return KeychainWrapper(serviceName: serviceName).string(forKey: tokenKey)
        }
        set {
            // Сохраняем или удаляем токен
            let keychain = KeychainWrapper(serviceName: serviceName)
            if let token = newValue {
                keychain.set(token, forKey: tokenKey)
            } else {
                keychain.removeObject(forKey: tokenKey)
            }
        }
    }
    func clearToken() {
        token = nil
    }
}
