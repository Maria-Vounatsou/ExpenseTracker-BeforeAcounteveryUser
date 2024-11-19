import CoreData
import SwiftUI
import Foundation
import CryptoKit

// MARK: - Notification Extensions
extension Notification.Name {
    static let didUpdateExpenses = Notification.Name("didUpdateExpenses")
    static let didDeleteCategoryFromEdit = Notification.Name("didDeleteCategoryFromEdit")
}

// MARK: - DataManager Extension for User Management
extension DataManager {
    func signUpUser(email: String, password: String, username: String) -> Bool {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let existingUser = try viewContext.fetch(fetchRequest)
            if !existingUser.isEmpty {
                print("User with email \(email) already exists.")
                return false
            }
            
            // Create a new user
            let newUser = UserEntity(context: viewContext)
            newUser.email = email
            newUser.password = hashPassword(password)
            newUser.username = username
            newUser.isLoggedIn = true
            
            try viewContext.save()
            print("User signed up successfully.")
            
            // Update sign-in status in AppStorage
            UserDefaults.standard.set(true, forKey: "isUserSignedIn")
            return true
        } catch {
            print("Failed to sign up user: \(error)")
            return false
        }
    }
    
    func authenticateUser(email: String, password: String) -> Bool {
        // Hash the input password for comparison
        let hashedPassword = hashPassword(password)

        // Fetch user entity from Core Data
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, hashedPassword)

        do {
            let results = try viewContext.fetch(fetchRequest)
            return !results.isEmpty // Return true if user exists
        } catch {
            print("Error authenticating user: \(error.localizedDescription)")
            return false
        }
    }

    func logOutUser() -> Bool {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isLoggedIn == YES")
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            results.forEach { $0.isLoggedIn = false }
            
            try viewContext.save()
            print("User logged out successfully.")
            
            // Update sign-in status in AppStorage
            UserDefaults.standard.set(false, forKey: "isUserSignedIn")
            return true
        } catch {
            print("Failed to log out user: \(error)")
            return false
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        // Convert the password string to Data
        let passwordData = Data(password.utf8)
        
        // Generate the SHA-256 hash
        let hashed = SHA256.hash(data: passwordData)
        
        // Convert the hash to a hexadecimal string for storage
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    func isUserSignedInCoreData() -> Bool {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isLoggedIn == YES")
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Failed to fetch user sign-in status: \(error)")
            return false
        }
    }
    
    func printStoredUsers() {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let users = try viewContext.fetch(fetchRequest)
            for user in users {
                print("Stored User - Email: \(user.email ?? ""), Password: \(user.password ?? ""), Username: \(user.username ?? "")")
            }
        } catch {
            print("Failed to fetch stored users: \(error)")
        }
    }
    func testHashing() {
        let plainPassword = "password"
        let hashed = hashPassword(plainPassword)
        print("Hashed Password: \(hashed)")
    }
}

// MARK: - DataManager Class
class DataManager: ObservableObject {
    
    // MARK: - Singleton Instance
    static let shared = DataManager(context: PersistenceController.shared.container.viewContext)
    
    // MARK: - Published Properties
    @Published var expensesItems: [ExpensesEntity] = []  // Stores fetched expenses
    @Published var categories: [String] = []  // Stores fetched categories
    
    var viewContext: NSManagedObjectContext
    
    // MARK: - Initializer
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.expensesItems = fetchExpenses()
        self.categories = fetchCategories()
        setupNotifications()
    }
    
    // MARK: - Notifications Setup
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidChange(notification:)),
            name: .NSManagedObjectContextObjectsDidChange,
            object: viewContext
        )
    }
    
    @objc private func contextDidChange(notification: Notification) {
        self.expensesItems = fetchExpenses()  // Refresh the expenses
        self.categories = fetchCategories()  // Refresh the categories
    }
    
    // MARK: - Fetching Data
    func fetchExpenses() -> [ExpensesEntity] {
        let request: NSFetchRequest<ExpensesEntity> = ExpensesEntity.fetchRequest()
        do {
            let fetchedItems = try viewContext.fetch(request)
            print("Remaining expenses by category: \(expensesByCategory)")  // Log the grouped expenses
            return fetchedItems
        } catch {
            print("Failed to fetch expenses: \(error)")
            return []
        }
    }
    
    func fetchCategories() -> [String] {
        let request: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
        request.predicate = NSPredicate(format: "deletedFlag == NO")  // Exclude deleted categories
        do {
            let results = try viewContext.fetch(request)
            let uniqueCategories = Set(results.map { $0.name ?? "" }).filter { !$0.isEmpty }  // Filter out empty names
            let sortedCategories = Array(uniqueCategories).sorted()  // Sort categories alphabetically
            print("Fetched Categories: \(sortedCategories)")
            return sortedCategories
        } catch {
            print("Failed to fetch categories: \(error)")
            return ["Personal", "Business", "Entertainment", "Home"]  // Default fallback categories
        }
    }
    
    // MARK: - Add/Update Data
    func addExpense(amount: Double, category: String, expenseDescription: String) -> ExpensesEntity? {
        let newExpense = ExpensesEntity(context: viewContext)  // Create a new ExpensesEntity
        newExpense.id = UUID()  // Generate a unique ID for the expense
        newExpense.amount = amount  // Set the amount for the expense
        newExpense.expenseDescription = expenseDescription  // Set the description for the expense
        newExpense.date = Date() // Set the current date for the expense
        
        setCategory(for: newExpense, withName: category)  // Set or create the category
        
        do {
            try viewContext.save()  // Save the context
            print("Expense added successfully")
            
            // Post notification after saving the new expense
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
            }
            return newExpense  // Return the newly added expense
            
        } catch {
            print("Failed to add expense: \(error)")
            return nil
        }
    }
    
    func setCategory(for expense: ExpensesEntity, withName categoryName: String) {
        if let category = categoryEntity(forName: categoryName) {
            expense.categoryRel = category  // Set the existing category
        } else {
            // Create a new category if none exists
            let newCategory = CategoriesEntity(context: viewContext)
            newCategory.name = categoryName
            expense.categoryRel = newCategory  // Assign the new category to the expense
        }
    }
    
    func saveContext() -> Bool {
        if viewContext.hasChanges {
            do {
                try viewContext.save()  // Save the context if there are changes
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
                }
                return true  // Return true if saving is successful
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
                return false  // Return false if saving fails
            }
        }
        return false  // Return false if there are no changes to save
    }
    
    // MARK: - Grouping Data
    var expensesByCategory: [String: [ExpensesEntity]] {
        Dictionary(grouping: expensesItems, by: { $0.categoryRel?.name ?? "Uncategorized" })  // Group by category name or "Uncategorized"
    }
    
    // MARK: - Deleting Data
    func deleteExpense(_ expense: ExpensesEntity) -> Bool {
        viewContext.delete(expense)  // Mark the expense for deletion
        do {
            try viewContext.save()  // Save the context
            print("Expense deleted and context saved")
            return true
        } catch {
            print("Failed to delete expense: \(error)")
            return false
        }
    }
    
    func permanentlyDeleteCategory(_ categoryEntity: CategoriesEntity) {
        viewContext.delete(categoryEntity)  // Permanently delete the category
        do {
            try viewContext.save()  // Save context after deletion
            print("Category permanently deleted.")
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
    
    // MARK: - Fetch Specific Data
    func categoryEntity(forName name: String) -> CategoriesEntity? {
        let fetchRequest: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        
        do {
            let categories = try viewContext.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Failed to fetch category with name: \(name), error: \(error)")
            return nil
        }
    }
    
    func fetchAllCategories() -> [String] {
        let request: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
        // No predicate to filter out deleted categories, includes all categories
        do {
            let results = try viewContext.fetch(request)
            let uniqueCategories = Set(results.map { $0.name ?? "" }).filter { !$0.isEmpty }
            return Array(uniqueCategories).sorted()
        } catch {
            print("Failed to fetch all categories: \(error)")
            return ["Personal", "Business", "Entertainment", "Home"]  // Default fallback categories
        }
    }
}
