//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Михаил on 03.12.2024.
//

import UIKit
import Kingfisher
final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func prepareForReuse() {
            super.prepareForReuse()
            cellImage.kf.cancelDownloadTask()
        }
    func config(with photo: Photo, completion: @escaping () -> Void) {
            dateLabel.text = photo.createdAt?.dateString()
            likeButton.setImage(
                photo.isLiked ? UIImage(named: "Active") : UIImage(named: "No Active"),
                for: .normal
            )
            
            cellImage.kf.indicatorType = .activity
            if let url = URL(string: photo.thumbImageURL) {
                cellImage.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "placeholder"),
                    options: [.transition(.fade(0.3))]
                ) { _ in
                    completion()
                }
            }
        }
}
extension Date {
    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU") // Для русской локализации
        return formatter.string(from: self)
    }
}
