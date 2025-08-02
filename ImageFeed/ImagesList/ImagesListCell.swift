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
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }

    
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
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        likeButton.setImage(likeImage, for: .normal)
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
