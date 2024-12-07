//
//  ViewController.swift
//  ImageFeed
//
//  Created by Михаил on 28.11.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - @IBOutlet properties
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let currentDate = Date()
    
    // MARK: - Private Methods
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row])
        else {
            return
        }
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    
}
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { } // TODO: - Добавить логику при нажатии на ячейку
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // 1
        
        guard let imageListCell = cell as? ImagesListCell else { // 2
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath) // 3
        return imageListCell // 4
    }
    
    
}
