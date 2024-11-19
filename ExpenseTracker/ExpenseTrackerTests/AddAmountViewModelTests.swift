//
//  AddAmountViewModelTests.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 7/11/24.
//


import XCTest
import SwiftUI
@testable import ExpenseTracker

final class AddAmountViewModelTests: XCTestCase {
    var viewModel: AddAmountViewModel!
    var mockDataManager: MockDataManager!
    
    override func setUp() {
        super.setUp()
        mockDataManager = MockDataManager(context: PersistenceController.preview.container.viewContext)
        viewModel = AddAmountViewModel(dataManager: mockDataManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockDataManager = nil
        super.tearDown()
    }
    
    func testInitialDataLoad() {
        // Test that categories load correctly
        XCTAssertEqual(viewModel.categories, ["Food", "Transport", "Entertainment"])
        XCTAssertEqual(viewModel.selectedCategory, "Food")
    }
    
    func testAddExpenseAmountSuccess() {
        // Arrange: Set up the conditions for the test
        viewModel.selectedCategory = "Food"
        viewModel.amount = 10.0
        viewModel.expenseDescription = "Lunch"
        
        // Act: Call the method to add an expense
        viewModel.addExpenseAmount()
        
        // Assert: Verify that addExpense was called on the mock data manager
        XCTAssertTrue(mockDataManager.addExpenseCalled, "Expected addExpense to be called")
        
        // Verify that a new expense was created with the correct values
        guard let addedExpense = mockDataManager.lastAddedExpense else {
            XCTFail("No expense was added.")
            return
        }
        
        XCTAssertEqual(addedExpense.amount, 10.0, "Expected amount to match the input")
        XCTAssertEqual(addedExpense.expenseDescription, "Lunch", "Expected description to match the input")
        XCTAssertEqual(addedExpense.categoryRel?.name, "Food", "Expected category to be 'Food'")
        
        // Verify that the fields were reset in the view model
        XCTAssertEqual(viewModel.amount, 0, "Amount should be reset after adding expense")
        XCTAssertEqual(viewModel.expenseDescription, "", "Description should be cleared after adding expense")
    }

    
    func testAddExpenseAmountFailsWithoutCategory() {
        // Test that adding an expense fails if no category is selected
        viewModel.selectedCategory = ""
        viewModel.amount = 10.0
        viewModel.expenseDescription = "Lunch"
        
        viewModel.addExpenseAmount()
        
        XCTAssertFalse(mockDataManager.addExpenseCalled, "Expected addExpense not to be called when no category is selected")
    }
    
    func testUpdateCategoriesFetchAll() {
        // Test fetching all categories, including deleted ones
        viewModel.updateCategories(fetchAll: true)
        XCTAssertEqual(viewModel.categories, ["Food", "Transport", "Entertainment"])
    }
    
    func testUpdateCategoriesNonDeleted() {
        // Modify the mock to simulate a deleted category
        mockDataManager.categories = ["Food", "Transport", "Deleted", "Entertainment"]
        
        viewModel.updateCategories(fetchAll: false)
        XCTAssertEqual(viewModel.categories, ["Food", "Transport", "Entertainment"])
    }
    
    func testClearFields() {
        // Set up some data
        viewModel.amount = 10.0
        viewModel.expenseDescription = "Dinner"
        
        // Call clearFields and check if fields are reset
        viewModel.clearFields()
        
        XCTAssertEqual(viewModel.amount, 0, "Amount should be cleared")
        XCTAssertEqual(viewModel.expenseDescription, "", "Description should be cleared")
    }
}
