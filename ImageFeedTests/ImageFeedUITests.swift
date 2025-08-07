//
//  ImageFeedUITests.swift
//  ImageFeedTests
//
//  Created by Михаил on 07.08.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
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
        loginTextField.typeText(".ru")

        webView.swipeUp()

        // Ввод пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")
        passwordTextField.tap()
        passwordTextField.typeText(" ")

        webView.swipeUp()

        // Нажать "Login"
        webView.buttons["Login"].tap()

        // Проверка появления первой ячейки в ленте
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Лента не появилась")
    }
    
    func testProfile() throws {
        // Подождать, пока загружается экран ленты (feed)
        sleep(3)

        // Перейти на экран профиля (tab с индексом 1, если он второй)
        app.tabBars.buttons.element(boundBy: 1).tap()

        // Проверить, что на экране профиля отображаются твои персональные данные
        XCTAssertTrue(app.staticTexts["Михаил"].exists)       // имя
        XCTAssertTrue(app.staticTexts["@mikemolchanov"].exists) // логин (замени на свой)

        // Нажать на кнопку выхода
        app.buttons["logout button"].tap()

        // Подтвердить выход в алерте
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        // Проверить, что вернулись на экран авторизации
        XCTAssertTrue(app.buttons["Authenticate"].exists)
    }

}
