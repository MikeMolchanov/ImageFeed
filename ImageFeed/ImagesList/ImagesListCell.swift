//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Михаил on 03.12.2024.
//

import UIKit
final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
}
