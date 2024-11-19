import SwiftUI
import Combine

class AddAmountViewModel: ObservableObject {
    // MARK: - Properties

    @Published var categories: [String] = []  // List of expense categories
    @Published var selectedCategory: String = ""  // Currently selected category
    @Published var amount: Double = 0  // Amount for the expense
    @Published var currencySymbol: String = Locale.current.currencySymbol ?? "$"  // Currency symbol
    @Published var expenseDescription: String = ""  // Description of the expense

    var dataManager: DataManager  // Reference to the DataManager for Core Data interactions

    // MARK: - Initializer

    // Initializer that loads initial data and sets up notification observers
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        loadInitialData()  // Load initial categories and set a default selection

        // Add observers for different category updates
        NotificationCenter.default.addObserver(self, selector: #selector(handleExpenseViewCategoryUpdate), name: .didUpdateExpenses, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditCategoryUpdate), name: .didDeleteCategoryFromEdit, object: nil)
    }

    // MARK: - Data Loading

    // Load initial categories from DataManager and set the first one as selected
    private func loadInitialData() {
        self.categories = dataManager.fetchAllCategories()  // Load all categories by default
        if !categories.isEmpty {
            self.selectedCategory = categories.first ?? ""  // Set the first category as the default selection
        }
    }
    
    // MARK: - Notification Handlers

    // Handle the category update notification from ExpenseView
    @objc func handleExpenseViewCategoryUpdate() {
        updateCategories(fetchAll: true)  // Fetch all categories, including deleted ones
    }

    // Handle the category update notification from EditCategoryView
    @objc func handleEditCategoryUpdate() {
        updateCategories(fetchAll: false)  // Fetch only non-deleted categories
    }

    // MARK: - Category Updates

    // Updates the list of categories based on the situation (all or non-deleted)
    func updateCategories(fetchAll: Bool) {
        if fetchAll {
            self.categories = dataManager.fetchAllCategories()  // Fetch all categories (including deleted)
        } else {
            self.categories = dataManager.fetchCategories()  // Fetch only non-deleted categories
        }
    }
    
    // MARK: - Deinitialization

    // Deinitializer to remove the notification observer
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didUpdateExpenses, object: nil)  // Remove observer when the view model is deallocated
        NotificationCenter.default.removeObserver(self, name: .didDeleteCategoryFromEdit, object: nil)
    }

    // MARK: - Expense Management

    // Adds an expense amount using the selected category
    func addExpenseAmount() {
        guard !selectedCategory.isEmpty else {
            print("No category selected. Cannot save expense.")  // Ensure a category is selected before saving
            return
        }
        
        // Attempt to add the expense using DataManager
        if let newExpense = dataManager.addExpense(amount: amount, category: selectedCategory, expenseDescription: expenseDescription) {
            print("Successfully added new expense with ID: \(newExpense.id?.uuidString ?? "Unknown ID")")  // Log the success
            
            // Check if the selected category is soft-deleted and unmark it
            if let categoryEntity = dataManager.categoryEntity(forName: selectedCategory), categoryEntity.deletedFlag {
                categoryEntity.deletedFlag = false  // Unmark the category from being soft deleted
                _ = dataManager.saveContext()  // Save the context after updating the category
                NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)  // Notify others
            }
            
            clearFields()  // Clear the form fields after successful save
        } else {
            print("Failed to add expense.")  // Log failure if the expense could not be added
        }
    }

    // MARK: - Utility Functions

    // Clears the form fields after saving an expense
    func clearFields() {
        self.amount = 0  // Reset the amount
        self.expenseDescription = ""  // Clear the description
    }
}
