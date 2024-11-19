//
//  ExpenseDetailViewModel.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 20/9/24.
//
import Foundation
import SwiftUI
import Combine

class DetailViewModel: ObservableObject {
    @Published var expenses: [ExpensesEntity]  // List of expenses to be displayed
    private var dataManager: DataManager  // Reference to DataManager for Core Data operations
    private var cancellables = Set<AnyCancellable>()  // Set to store Combine subscriptions
    
    // Initializer that takes a list of expenses and a DataManager reference
    init(expenses: [ExpensesEntity], dataManager: DataManager) {
        self.expenses = expenses
        self.dataManager = dataManager
        
        // Observe notifications for expense updates and refresh the expenses list when notified
        NotificationCenter.default.publisher(for: .didUpdateExpenses)
            .receive(on: RunLoop.main)  // Ensure updates are processed on the main thread
            .sink { [weak self] _ in
                self?.fetchExpenses()  // Fetch the updated list of expenses
            }
            .store(in: &cancellables)  // Store the subscription in cancellables
    }
    
    // Computed property to calculate total amount for expenses
    var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    // Fetch updated expenses from DataManager
    func fetchExpenses() {
        // Fetch expenses from DataManager and filter them based on current categories or IDs
        let updatedExpenses = dataManager.fetchExpenses().filter { expense in
            // Only include expenses that are already in the list (by matching IDs)
            expenses.contains { $0.id == expense.id }
        }
        self.expenses = updatedExpenses  // Update the published expenses list
    }
    
    // Delete an expense from Core Data and update the local list
    func deleteExpenseFromDetail(at offsets: IndexSet) {
        offsets.forEach { index in
            let expenseEntity = expenses[index]  // Get the expense to delete
            
            // Attempt to delete the expense from Core Data
            if dataManager.deleteExpense(expenseEntity) {
                // Remove the expense from the local list if deletion succeeds
                expenses.remove(at: index)
            } else {
                // Handle deletion failure (optional: show an alert or message)
                print("Failed to delete expense with id: \(expenseEntity.id?.uuidString ?? "unknown")")
            }
        }
        
        // Post a notification to update the UI after deletion
        NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
    }
    
    // Date formatter function
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Format: "31/10/2024"
        return formatter.string(from: date)
    }
}
