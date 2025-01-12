//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Михаил on 07.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let avatarImageView : UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "Photo")
        view.image = image
        return view
    }()
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        let fontSize: CGFloat = 23.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return label
    }()
    private let loginNameLabel : UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        let fontSize: CGFloat = 13.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        return label
    }()
    private let descriptionLabel : UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .ypWhite
        let fontSize: CGFloat = 13.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        return label
    }()
    private let logoutButton : UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(named: "Exit")
        button.setImage(buttonImage, for: .normal)
        return button
    }()
    private func setupViews() {
            [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
//        let profileImage = UIImage(named: "Photo")
//        let avatarImageView = UIImageView(image: profileImage)
//        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(avatarImageView)
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
//        let nameLabel = UILabel()
//        nameLabel.text = "Екатерина Новикова"
//        nameLabel.textColor = .ypWhite
//        let fontSize: CGFloat = 23.0
//        nameLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
//        self.label = nameLabel
        
//        let loginNameLabel = UILabel()
//        loginNameLabel.text = "@ekaterina_nov"
//        loginNameLabel.textColor = .ypGray
//        let fontSize2: CGFloat = 13.0
//        loginNameLabel.font = UIFont.systemFont(ofSize: fontSize2, weight: .regular)
//        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(loginNameLabel)
        loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
//        self.label = loginNameLabel
        
//        let descriptionLabel = UILabel()
//        descriptionLabel.text = "Hello, world!"
//        descriptionLabel.textColor = .ypWhite
//        let fontSize3: CGFloat = 13.0
//        descriptionLabel.font = UIFont.systemFont(ofSize: fontSize3, weight: .regular)
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
//        self.label = descriptionLabel
        
//        let logoutButton = UIButton()
//        let buttonImage = UIImage(named: "Exit")
//        logoutButton.setImage(buttonImage, for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
    }
    
}
