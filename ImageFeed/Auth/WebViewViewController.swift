//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Михаил on 19.01.2025.
//

import UIKit
import WebKit
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(didTapCancel)
            )

        webView.accessibilityIdentifier = "UnsplashWebView"
        
//        #if DEBUG
//        if ProcessInfo.processInfo.arguments.contains("UITEST") {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.delegate?.webViewViewController(self, didAuthenticateWithCode: "test_code")
//            }
//            return
//        }
//        #endif

        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: []) { [weak self] webView, _ in
            self?.presenter?.didUpdateProgressValue(webView.estimatedProgress)
        }
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
    }




    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public func load(request: URLRequest) {
        webView.load(request)
    } 
    
    public func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    public func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    @objc private func didTapCancel() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    deinit {
        estimatedProgressObservation?.invalidate()
    }

}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if
            let url = navigationAction.request.url,
            let code = presenter?.code(from: url)
        {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }

    }
}
extension WebViewViewController: WebViewViewControllerProtocol {}
