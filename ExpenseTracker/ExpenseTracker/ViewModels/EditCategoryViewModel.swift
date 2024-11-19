import SwiftUI
import CoreData

enum AlertType {
case deleteConfirmation
case categoryIssue
}

class EditCategoryViewModel: ObservableObject {
    @Published var addCategory: String = ""  // Stores the name of the category to be added
    @Published var deleteCategory: String = ""  // Stores the name of the category to be deleted
    @Published var alertMessage: String = ""
    @Published var showAlert = false
    var alertType: AlertType?
    
    private var dataManager: DataManager  // Reference to the DataManager for Core Data interactions
    
    // Initializer that accepts DataManager
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // Action to add a new category
    func addCategoryAction() {
        // Trim white spaces from the category name
        let trimmedCategory = addCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedCategory.isEmpty else {
            alertMessage = "Category name cannot be empty."
            alertType = .categoryIssue
            showAlert = true  // Show alert when the category name is empty after trimming
            return
        }
        
        // Fetch non-deleted categories
        let categories = dataManager.fetchCategories()  // Fetch only categories that are not flagged as deleted
        
        // Check if the trimmed category already exists (ignoring deleted categories)
        if categories.contains(trimmedCategory) {
            alertMessage = "Category '\(trimmedCategory)' already exists."
            alertType = .categoryIssue
            showAlert = true  // Show alert if the category already exists
        } else {
            // Create a new category in Core Data
            let newCategory = CategoriesEntity(context: dataManager.viewContext)
            newCategory.name = trimmedCategory  // Set the new category name
            
            // Save the context and check for success
            if dataManager.saveContext() {
                addCategory = ""  // Clear the input field after successful addition
                print("Added new category: \(newCategory.name ?? "")")
                
                // Notify other views or components that the data has changed
                NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
            } else {
                alertMessage = "Failed to save the new category."
                alertType = .categoryIssue
                showAlert = true  
            }
        }
    }
    
    func deleteCategoryAction() {
        guard !deleteCategory.isEmpty else {
            print("Please specify a category to delete.")
            return
        }
        
        let categories = dataManager.fetchAllCategories()
        if categories.contains(deleteCategory) {
            if let categoryEntity = dataManager.categoryEntity(forName: deleteCategory) {
                let expensesForCategory = dataManager.expensesItems.filter { $0.categoryRel?.name == categoryEntity.name }
                
                if !expensesForCategory.isEmpty && categoryEntity.deletedFlag == false {
                    alertMessage = "Deleting this category will also delete all associated expenses. Are you sure?"
                    alertType = .deleteConfirmation
                    showAlert = true
                } else {
                    dataManager.permanentlyDeleteCategory(categoryEntity)
                    deleteCategory = ""
                    NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
                }
            }
        } else {
            print("Category not found.")
        }
    }

    func confirmDeleteCategory() {
        print("confirmDeleteCategory: Deleted category: \(deleteCategory)")

        if let categoryEntity = dataManager.categoryEntity(forName: deleteCategory) {
            let expensesForCategory = dataManager.expensesItems.filter { $0.categoryRel == categoryEntity }
            
            // Delete all associated expenses
            for expense in expensesForCategory {
                dataManager.viewContext.delete(expense)
            }
            
            // Save context after expense deletion
            _ = dataManager.saveContext()
            
            // Permanently delete the category
            dataManager.permanentlyDeleteCategory(categoryEntity)
            deleteCategory = ""
            NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
        }
    }
}
