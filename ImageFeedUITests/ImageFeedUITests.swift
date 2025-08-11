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
        app.launchArguments.append("--uitesting") // 👈 передаём аргумент для приложения
        app.launch()
    }

    
    func testAuth() throws {
        // Нажать кнопку авторизации
        app.buttons["Authenticate"].tap()
        
        // Найти WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")
        
        // Ввод логина
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("misha995@yandex.ru")
        
        webView.swipeUp()
        
        // Ввод пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")
        passwordTextField.tap()
        passwordTextField.typeText("Mazasplash228")
        
        webView.swipeUp()
        
        // Нажать "Login"
        webView.buttons["Login"].tap()
        
        // Проверка появления первой ячейки в ленте
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Лента не появилась")
    }
    
    func testFeed() throws {
        // Ждём, пока откроется лента после авторизации
        sleep(3) // или дольше, если авторизация долгая

        let firstCell = app.cells["feed cell"].firstMatch

        // Ждём появления первой ячейки
        XCTAssertTrue(firstCell.waitForExistence(timeout: 30), "Первая ячейка ленты не появилась")


        // Лайк
        let likeButton = firstCell.buttons["like button"]
        XCTAssertTrue(likeButton.exists, "Кнопка лайка не найдена в первой ячейке")
        likeButton.tap()

        // Скролл
        app.swipeUp()
        sleep(1)
        app.swipeDown()
    }


    
    func testProfile() throws {
        // Подождать, пока загружается экран ленты (feed)
        sleep(3)
        
        // Перейти на экран профиля (tab с индексом 1, если он второй)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Проверить, что на экране профиля отображаются твои персональные данные
        XCTAssertTrue(app.staticTexts["Михаил"].exists)       // имя
        XCTAssertTrue(app.staticTexts["@mikemolchanov"].exists) // логин (
        
        // Нажать на кнопку выхода
        app.buttons["logout button"].tap()
        
        // Подтвердить выход в алерте
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        // Проверить, что вернулись на экран авторизации
        XCTAssertTrue(app.buttons["Authenticate"].exists)
    }
}
