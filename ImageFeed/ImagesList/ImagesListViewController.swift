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
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let currentDate = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    
    // MARK: - Private Methods
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.dateLabel.text = photo.createdAt?.dateString()
        cell.likeButton.setImage(
            photo.isLiked ? UIImage(named: "Active") : UIImage(named: "No Active"),
            for: .normal
        )
        
        // Загрузка изображения из сети
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: [.transition(.fade(0.3))]
            )
        }
    }
    private func refreshFeed() {
        imagesListService.photos = [] // Очищаем текущие фото
        imagesListService.fetchPhotosNextPage() // Загружаем свежие
    }
    private func setupObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        guard newCount > oldCount else { return }
        
        photos = imagesListService.photos
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        refreshFeed()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL) // Передаем URL вместо UIImage
        }
    }
    
    
}
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
}
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        let photo = photos[indexPath.row]
        cell.config(with: photo) { [weak self] in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
}

