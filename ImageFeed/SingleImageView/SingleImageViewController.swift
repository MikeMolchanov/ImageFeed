//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Михаил on 09.12.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - @IBOutlet properties
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Properties
    var image: UIImage?{
        didSet {
            guard isViewLoaded else { return } // 1
            imageView.image = image // 2
            guard let image else { return }
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL = imageURL else { return }
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private Methods
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let image = image {
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        } else if let imageURL = imageURL {
            loadImage(from: imageURL)
        }
    }
    private func loadImage(from url: URL) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [.transition(.fade(0.3))]
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.image = value.image // Сохраняем загруженное изображение
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("Ошибка загрузки: \(error)")
                
            }
        }
    }
}
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
