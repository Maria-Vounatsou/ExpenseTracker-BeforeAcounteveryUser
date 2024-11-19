import Combine
import CoreData
import DGCharts

class PieChartViewModel: ObservableObject {
    @Published var pieChartDataEntries: [PieChartDataEntry] = []  // Holds data entries for the pie chart
    @Published var deletedCategories: Set<String> = []
    
    // A reference to DataManager for fetching expenses
    private var dataManager: DataManager
    
    // Initializer that takes DataManager and sets up observers for Core Data updates
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        updateChartData()  // Initial chart data update
        
        // Listen for Core Data updates and refresh the chart when data changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateChartDataNotification),
            name: .didUpdateExpenses,
            object: nil
        )
    }
    
    // Called when the notification for Core Data updates is received
    @objc private func updateChartDataNotification() {
        print("Pie chart data is being updated")
        updateChartData()  // Refresh the pie chart data
    }
    
    // Fetches expenses and updates the chart data
    func updateChartData() {
        let expenses = dataManager.fetchExpenses()  // Fetch all expenses from DataManager
        calculateChartData(from: expenses)  // Calculate data entries for the pie chart
    }
    
    // Calculates pie chart data from a list of expenses, grouping by category
    private func calculateChartData(from expenses: [ExpensesEntity]) {
        // Filter out expenses belonging to deleted categories by checking deletedFlag
        let filteredExpenses = expenses.filter { expense in
            guard let category = expense.categoryRel else { return false }
            return !category.deletedFlag  // Exclude categories with deletedFlag set to true
        }
        
        // Group expenses by their category name, or "Uncategorized" if no category is set
        let groupedExpenses = Dictionary(grouping: filteredExpenses, by: { $0.categoryRel?.name ?? "Uncategorized" })
        
        // Create PieChartDataEntry for each category by summing up the total amounts
        let newEntries = groupedExpenses.compactMap { category, expenses -> PieChartDataEntry? in
            let totalAmount = expenses.reduce(0) { $0 + $1.amount }  // Sum of amounts per category
            return PieChartDataEntry(value: Double(totalAmount), label: category)  // Create a data entry
        }
        
        // Update the chart data entries on the main thread
        DispatchQueue.main.async {
            self.pieChartDataEntries = newEntries.isEmpty ? self.defaultEntries() : newEntries
        }
    }
    
    // Function to calculate and return the total amount as a formatted string
    func calculateTotalAmount() -> String {
        let total = pieChartDataEntries.reduce(0) { $0 + $1.value } // Assuming `value` is the amount for each entry
        return String(format: "Expenses\n%.2f", total) // Format to two decimal places
    }
    
    // Provides default entries if no data is available for the pie chart
    private func defaultEntries() -> [PieChartDataEntry] {
        return ["Category1", "Category2", "Category3"].map { PieChartDataEntry(value: 10, label: $0) }  // Default categories with placeholder values
    }
}

