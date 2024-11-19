import Foundation
@testable import ExpenseTracker

class MockDataManager: DataManager {
    var addExpenseCalled = false
    var lastAddedExpense: ExpensesEntity?
    
    override func fetchAllCategories() -> [String] {
        return ["Food", "Transport", "Entertainment"]
    }
    
    override func fetchCategories() -> [String] {
        // Simulates returning only non-deleted categories
        return ["Food", "Transport", "Entertainment"]
    }
    
    override func addExpense(amount: Double, category: String, expenseDescription: String) -> ExpensesEntity? {
            addExpenseCalled = true
            let newExpense = ExpensesEntity(context: viewContext)
            newExpense.id = UUID()
            newExpense.amount = amount
            newExpense.expenseDescription = expenseDescription
            newExpense.date = Date()
            
            setCategory(for: newExpense, withName: category)
            
            lastAddedExpense = newExpense
            return newExpense
        }}

