//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Михаил on 25.07.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    
    // 1. Создаем моковый URLProtocol
    private class MockURLProtocol: URLProtocol {
        static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let handler = MockURLProtocol.requestHandler else {
                XCTFail("Request handler не настроен")
                return
            }
            
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() {}
    }
    
    // 2. Настройка теста
    override func setUp() {
        super.setUp()
        
        // Создаем конфигурацию с нашим протоколом
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        // Сохраняем оригинальную конфигурацию
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }
    
    // 3. Тестовый случай
    func testFetchPhotosSuccess() {
        // Подготовка тестовых данных
        let json = """
        [{
            "id": "test1",
            "created_at": "2020-01-01T00:00:00Z",
            "updated_at": "2020-01-01T00:00:00Z",
            "width": 100,
            "height": 100,
            "color": "#FFFFFF",
            "blur_hash": "TEST",
            "likes": 10,
            "liked_by_user": false,
            "description": "Test photo",
            "urls": {
                "raw": "https://test.com/raw.jpg",
                "full": "https://test.com/full.jpg",
                "regular": "https://test.com/regular.jpg",
                "small": "https://test.com/small.jpg",
                "thumb": "https://test.com/thumb.jpg"
            }
        }]
        """.data(using: .utf8)!
        
        // Вывод полного JSON для проверки (добавьте эти строки)
        print("=== Полный JSON для теста ===")
        print(String(data: json, encoding: .utf8) ?? "Не удалось распечатать JSON")
        print("============================")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, json)
        }
        
        let service = ImagesListService()
        let expectation = self.expectation(description: "Photos loaded")
        
        // Act
        var observer: NSObjectProtocol?
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            // Assert
            guard notification.object as? ImagesListService === service else { return }
            
            XCTAssertEqual(service.photos.count, 1)
            XCTAssertEqual(service.photos.first?.id, "test1")
            
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
            expectation.fulfill()
        }
        
        service.fetchPhotosNextPage()
        
        // Wait
        wait(for: [expectation], timeout: 5.0)
    }
}
