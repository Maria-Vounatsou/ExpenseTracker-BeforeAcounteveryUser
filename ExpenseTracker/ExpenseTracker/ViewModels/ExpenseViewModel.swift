import SwiftUI
import CoreData
import Combine


struct ExpenseSnapshot {
    let id: UUID
    let amount: Double
    let description: String
    let date: Date
}

class ExpenseViewModel: ObservableObject {
    @Published var categoriesWithExpenses: [String] = []  // Stores categories that have associated expenses
    @Published var shouldRefresh = false  // Trigger to refresh the view
    var dataManager: DataManager  // Reference to DataManager for interacting with Core Data
    private var cancellables = Set<AnyCancellable>()  // Set to store Combine subscriptions
    
    // A local list to keep track of categories marked as "deleted" for ExpenseView only
    var deletedCategories: Set<String> = []
    
    private var lastDeletedCategory: CategoriesEntity?  // Stores the last deleted category for undo
    private var lastDeletedExpenses: [ExpenseSnapshot] = []  // Stores expenses for the last deleted category
    
    // Initializer for ExpenseViewModel that subscribes to expense updates and triggers fetches
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        fetchCategoriesWithExpenses()  // Initial fetch of categories with expenses
        
        // Subscribe to notification for expense updates and debounce rapid updates
        NotificationCenter.default.publisher(for: .didUpdateExpenses)
            .receive(on: RunLoop.main)  // Ensure updates are received on the main thread
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)  // Debounce to limit update frequency
            .sink { [weak self] _ in
                self?.fetchCategoriesWithExpenses()  // Fetch categories when expenses change
                self?.shouldRefresh.toggle()  // Toggle refresh flag to force view update
            }
            .store(in: &cancellables)  // Store the subscription to cancellables
    }
    
    // MARK: - Undo Last Delete
    func undoLastDelete() {
        guard let categoryToRestore = lastDeletedCategory else {
            print("No category to undo.")
            return
        }
        
        // Restore the deleted category
        categoryToRestore.deletedFlag = false
        
        // Re-create each deleted expense and associate it with the restored category
        for expenseSnapshot in lastDeletedExpenses {
            let restoredExpense = ExpensesEntity(context: dataManager.viewContext)
            
            restoredExpense.id = expenseSnapshot.id
            restoredExpense.amount = expenseSnapshot.amount
            restoredExpense.expenseDescription = expenseSnapshot.description
            restoredExpense.categoryRel = categoryToRestore
            restoredExpense.date = expenseSnapshot.date
        }

        // Save the context to persist the undo operation
       _ = dataManager.saveContext()
        
        // Clear the last deleted references after restoring
        lastDeletedCategory = nil
        lastDeletedExpenses.removeAll()
        
        // Notify views of data changes
        NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
        fetchCategoriesWithExpenses()
    }

    // MARK: - Fetch Categories with Expenses    // Fetches categories with expenses from DataManager, filtering out those marked as deleted
       func fetchCategoriesWithExpenses() {
           let allCategories = dataManager.fetchCategories()
           self.categoriesWithExpenses = allCategories.filter { category in
               guard let categoryEntity = dataManager.categoryEntity(forName: category) else { return false }
               return !(dataManager.expensesByCategory[category]?.isEmpty ?? true) && !categoryEntity.deletedFlag
           }
       }
    
    // MARK: - Delete Category
    func deleteCategory(at offsets: IndexSet) {
        let categoriesToDelete = offsets.map { categoriesWithExpenses[$0] }
        
        for category in categoriesToDelete {
            if let categoryEntity = dataManager.categoryEntity(forName: category) {
                
                // Capture a snapshot of the associated expenses for undo
                if let expenses = dataManager.expensesByCategory[category] {
                    lastDeletedExpenses = expenses.map { expense in
                        ExpenseSnapshot(
                            id: expense.id ?? UUID(),  // Use the original ID or fallback to a new UUID if nil
                            amount: expense.amount,
                            description: expense.expenseDescription ?? "",
                            date: expense.date ?? Date()
                        )
                    }
                } else {
                    lastDeletedExpenses = []  // If no expenses are associated, set to an empty array
                }
                
                // Save the category for potential undo
                lastDeletedCategory = categoryEntity
                
                // Mark the category as deleted
                categoryEntity.deletedFlag = true
                
                // Delete associated expenses from Core Data
                if let expenses = dataManager.expensesByCategory[category] {
                    for expense in expenses {
                        _ = dataManager.deleteExpense(expense)
                    }
                }
                _ = dataManager.saveContext()  // Save changes to persist deletion
                NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)  // Notify the app of data change
            }
        }
        fetchCategoriesWithExpenses()  // Refresh categories with expenses after deletion
    }

    // MARK: - Expenses for Category       // Returns the list of expenses for a given category
       func expenses(for category: String) -> [ExpensesEntity] {
           return dataManager.expensesByCategory[category] ?? []  // Return expenses for the category or an empty list
       }
   }
