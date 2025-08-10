//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Михаил on 03.12.2024.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    var onLikeButtonTapped: (() -> Void)?
    weak var delegate: ImagesListCellDelegate?
    
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction private func likeButtonTapped(_ sender: UIButton) {
        onLikeButtonTapped?()
    }
    
    
    override func prepareForReuse() {
            super.prepareForReuse()
            cellImage.kf.cancelDownloadTask()
            cellImage.image = nil
            cellImage.contentMode = .center
            likeButton.setImage(nil, for: .normal)
        }

        func config(with photo: Photo, completion: @escaping () -> Void) {
            dateLabel.text = photo.createdAt?.dateString()
            setIsLiked(photo.isLiked)
            cellImage.kf.indicatorType = .activity
            cellImage.contentMode = .center
            if let url = URL(string: photo.thumbImageURL) {
                cellImage.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "Plug"),
                    options: [.transition(.fade(0.3))]
                ) { _ in
                    self.cellImage.contentMode = .scaleAspectFill
                    completion()
                }
            }
        }

        func setIsLiked(_ isLiked: Bool) {
            let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
            likeButton.setImage(likeImage, for: .normal)
            // идентификаторы для UI тестов
            likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
        }

        override func awakeFromNib() {
            super.awakeFromNib()
            // идентификаторы для UI тестов
            self.accessibilityIdentifier = "feed cell"
            // Примечание: не ставим тут likeButton.accessibilityIdentifier,
            // он задаётся в setIsLiked чтобы отражать текущий state.
            cellImage.translatesAutoresizingMaskIntoConstraints = false
            cellImage.contentMode = .scaleAspectFill
            cellImage.clipsToBounds = true
        }
    }

extension Date {
    func dateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
}
