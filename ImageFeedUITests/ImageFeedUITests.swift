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
        app.launchArguments.append("UITEST") // ключ для мок-авторизации
        app.launchEnvironment["IS_TESTING"] = "true"
        app.launch()
    }




    
    func testAuth() throws {
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10))
        authenticateButton.tap()
        
        // Ждём, пока лента загрузится (мок сработает через 1 секунду)
        let cell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15), "Лента не появилась")
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


    
    func testProfile() {
        let app = XCUIApplication()
        app.launch()

        // Ждём, пока таббар появится
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Таббар не появился")

        // Находим кнопку профиля в таббаре и нажимаем
        let profileButton = tabBar.buttons.element(boundBy: 1)
        XCTAssertTrue(profileButton.exists, "Кнопка профиля не найдена")
        profileButton.tap()

        // Дальше можно проверить, что профиль загрузился, например:
        let profileTitle = app.staticTexts["ProfileTitle"] // пример идентификатора
        XCTAssertTrue(profileTitle.waitForExistence(timeout: 5))
    }

    
    
}
