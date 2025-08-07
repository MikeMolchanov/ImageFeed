//
//  WebViewTestsSpies.swift
//  ImageFeedTests
//
//  Created by Михаил on 06.08.2025.
//

import Foundation
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {}

    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?

    private(set) var loadRequestCalled: Bool = false
    private(set) var lastRequest: URLRequest?

    func load(request: URLRequest) {
        loadRequestCalled = true
        lastRequest = request
    }

    func setProgressValue(_ newValue: Float) {}

    func setProgressHidden(_ isHidden: Bool) {}
}
