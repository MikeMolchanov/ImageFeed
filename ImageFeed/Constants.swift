//
//  Constants.swift
//  ImageFeed
//
//  Created by Михаил on 11.01.2025.
//

import UIKit

enum Constants {
    static let authViewControllerID = "AuthViewController"
    static let accessKey = "KLjJjKd0HAHZefLoKnLVZ4ZfoJSiksS-riusDQ7l-R8"
    static let secretKey = "BUMJ2xFUy2GSnNNoRb07hBIY_DseyP5LcdjSxR54lno"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Failed to create defaultBaseURL")
        }
        return url
    }()    
}
