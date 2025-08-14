//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Михаил on 08.08.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("UITests")
        app.launch()
    }

    
    func testAuth() throws {
        // Нажать кнопку авторизации
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5), "Кнопка 'Authenticate' не найдена")
        authenticateButton.tap()
        
        // Подождать, пока откроется WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")
        
        // Ввести логин
        let loginTextField = webView.textFields.element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("misha995@yandex.ru")
        
        webView.swipeUp()
        
        // Ввести пароль
        let passwordTextField = webView.secureTextFields.element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")
        passwordTextField.tap()
        passwordTextField.typeText("Mazasplash228")
        
        webView.swipeUp()
        
        // Нажать "Login"
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.exists, "Кнопка 'Login' не найдена")
        loginButton.tap()
        
        // Проверить, что открылась лента
        let cell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Лента не появилась")
    }
    
    func testFeed() throws {
        // Ждём появления первой ячейки в ленте
        let firstCell = app.cells["feed cell"].firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 30), "Первая ячейка ленты не появилась")
        
        // Скроллим
        app.swipeUp()
        sleep(1)
        
        // Лайк
        let likeButton = firstCell.buttons["like button"]
        XCTAssertTrue(likeButton.exists, "Кнопка лайка не найдена в первой ячейке")
        likeButton.tap()
        sleep(1)
        
        // Снять лайк
        likeButton.tap()
        sleep(1)
        
        // Открыть картинку
        firstCell.tap()
        
        // Ждём, пока картинка откроется
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Картинка не открылась")
        
        // Увеличить
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        
        // Уменьшить
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        // Вернуться на ленту
        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.exists, "Кнопка 'Back' не найдена")
        backButton.tap()
    }
    
    func testProfile() throws {
        // Ждём появления ленты
        let firstCell = app.cells["feed cell"].firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 30), "Лента не появилась")
        
        // Переход на профиль
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Таббар не появился")
        
        let profileButton = tabBar.buttons.element(boundBy: 1)
        XCTAssertTrue(profileButton.exists, "Кнопка профиля не найдена")
        profileButton.tap()
        
        // Проверка данных профиля
        let nameLabel = app.staticTexts["ProfileName"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5), "Имя пользователя не найдено")
        
        let loginLabel = app.staticTexts["ProfileLogin"]
        XCTAssertTrue(loginLabel.exists, "Логин пользователя не найден")
        
        let descriptionLabel = app.staticTexts["ProfileDescription"]
        XCTAssertTrue(descriptionLabel.exists, "Описание пользователя не найдено")
        
        // Logout
        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(logoutButton.exists, "Кнопка Logout не найдена")
        logoutButton.tap()
        
        // Проверяем, что открылся экран авторизации
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5), "Кнопка 'Authenticate' не появилась после выхода")
    }
    
}
