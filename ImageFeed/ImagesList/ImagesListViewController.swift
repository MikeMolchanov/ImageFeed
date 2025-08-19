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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let currentDate = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private var isUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }

    // MARK: - Private Methods
    
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
        tableView.reloadData()
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        setupObserver()
        refreshFeed()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            
            let photo = imagesListService.photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
}
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = imagesListService.photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count - 1 {
            if !isUITest {
                imagesListService.fetchPhotosNextPage()
            }
        }
    }
}
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            assertionFailure("Не удалось кастануть ячейку в ImagesListCell")
            return UITableViewCell()
        }
        
        let photo = imagesListService.photos[indexPath.row]
        cell.config(with: photo) { [weak self] in
            cell.accessibilityIdentifier = "feed cell"
        }

        cell.delegate = self

        cell.onLikeButtonTapped = { [weak self] in
            guard let self = self else { return }
            var photo = self.imagesListService.photos[indexPath.row]
            let newIsLiked = !photo.isLiked
            UIBlockingProgressHUD.show()
            self.imagesListService.changeLike(photoId: photo.id, isLike: newIsLiked) { result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    switch result {
                    case .success:
                        photo.isLiked = newIsLiked
                        self.imagesListService.photos[indexPath.row] = photo
                    case .failure(let error):
                        print("Ошибка при изменении лайка: \(error)")
                    }
                }
            }
        }
        
        cell.accessibilityIdentifier = "feed cell"
        return cell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = imagesListService.photos[indexPath.row]

        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
//                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    break
                case .failure(let error):
                    print("Ошибка при изменении лайка: \(error)")

                    // алерт
                }
            }
        }
    }
}

