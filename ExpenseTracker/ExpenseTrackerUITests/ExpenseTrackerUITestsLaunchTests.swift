//
//  ExpenseTrackerUITestsLaunchTests.swift
//  ExpenseTrackerUITests
//
//  Created by Vounatsou, Maria on 13/9/24.
//

import XCTest

final class ExpenseTrackerUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testAddExpense() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to Add Expense screen (ensure the "AddExpenseButton" is accessible)
        app.buttons["AddExpenseButton"].tap()
        
        // Enter expense amount
        let amountField = app.textFields["AmountTextField"]
        amountField.tap()
        amountField.typeText("50")
        
        // Enter description
        let descriptionField = app.textFields["DescriptionTextField"]
        descriptionField.tap()
        descriptionField.typeText("Groceries")
        
        // Select a category
        let categoryPicker = app.pickers["CategoryPicker"]
        categoryPicker.tap()
        categoryPicker.pickerWheels.element.adjust(toPickerWheelValue: "Food")
        
        // Tap Save button
        app.buttons["SaveButton"].tap()
        
        // Verify that the new expense has been added
        XCTAssertTrue(app.staticTexts["Groceries"].exists, "Expense description 'Groceries' should be present on the screen")
        XCTAssertTrue(app.staticTexts["50"].exists, "Expense amount '50' should be present on the screen")
    }
}

