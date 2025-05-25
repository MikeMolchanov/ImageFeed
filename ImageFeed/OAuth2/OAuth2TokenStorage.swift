//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Михаил on 30.04.2025.
//

import Foundation

final class OAuth2TokenStorage {
    // 1. Синглтон для доступа из любого места
    static let shared = OAuth2TokenStorage()
    private init() {}
    // 2. Ключ для сохранения в UserDefaults
    private let tokenKey = "accessToken"
    // 3. Вычислимое свойство для работы с токеном
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
