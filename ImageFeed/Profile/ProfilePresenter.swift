//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Михаил on 07.08.2025.
//

// ProfilePresenter.swift

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        let profile = ProfileService.shared.profile
        view?.updateProfileDetails(
            name: profile?.name ?? "",
            loginName: profile?.loginName ?? "",
            bio: profile?.bio ?? ""
        )

        if let urlString = ProfileImageService.shared.avatarURL,
           let url = URL(string: urlString) {
            view?.updateAvatar(url: url)
        }
    }

    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
}
