//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Михаил on 01.06.2025.
//

import Foundation
import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }

}
