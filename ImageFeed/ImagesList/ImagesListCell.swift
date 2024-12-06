//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Михаил on 03.12.2024.
//

import UIKit
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
}
