//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Михаил on 07.12.2024.
//

import UIKit

class ProfileViewController: UIViewController {
    private var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileImage = UIImage(named: "Photo")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        let fontSize: CGFloat = 23.0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        self.label = label
        
        let label2 = UILabel()
        label2.text = "@ekaterina_nov"
        label2.textColor = .ypGray
        let fontSize2: CGFloat = 13.0
        label2.font = UIFont.systemFont(ofSize: fontSize2, weight: .regular)
        label2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label2)
        label2.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        label2.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        self.label = label2
        
        let label3 = UILabel()
        label3.text = "Hello, world!"
        label3.textColor = .ypWhite
        let fontSize3: CGFloat = 13.0
        label3.font = UIFont.systemFont(ofSize: fontSize3, weight: .regular)
        label3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label3)
        label3.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 8).isActive = true
        self.label = label3
        
        let button = UIButton()
        let buttonImage = UIImage(named: "Exit")
        button.setImage(buttonImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
}
