//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Михаил on 03.08.2025.
//

import Foundation
import WebKit
import UIKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        cleanCookies()
        clearServicesData()
        switchToAuthViewController()
        OAuth2TokenStorage.shared.clearToken()
        ProfileService.shared.profile = nil
        ProfileImageService.shared.avatarURL = nil
        ImagesListService.shared.photos = []


    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func clearServicesData() {
        OAuth2TokenStorage.shared.clearToken()
        ProfileService.shared.profile = nil
        ProfileImageService.shared.avatarURL = nil
        ImagesListService.shared.photos = []
    }

    private func switchToAuthViewController() {
        guard
            let window = UIApplication.shared.windows.first,
            let splashVC = window.rootViewController as? SplashViewController
        else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController")
            return
        }

        splashVC.present(authVC, animated: true)
    }
}

