//
//  ContentView.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 6/9/24.
//

import SwiftUI
import CoreData
import DGCharts

struct ExpenseView: View {
    @Binding var presentSideMenu: Bool
    @State private var isNavigationActive = false
    @StateObject private var pieViewModel: PieChartViewModel
    @StateObject private var expenseViewModel: ExpenseViewModel
    @State private var showAddAmountView = false
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    // Custom initializer to pass DataManager and initialize view models
    init(presentSideMenu: Binding<Bool>, dataManager: DataManager) {
        _presentSideMenu = presentSideMenu  // Initialize the Binding for side menu state
        _pieViewModel = StateObject(wrappedValue: PieChartViewModel(dataManager: dataManager))  // Initialize PieChartViewModel with DataManager
        _expenseViewModel = StateObject(wrappedValue: ExpenseViewModel(dataManager: dataManager))  // Initialize ExpenseViewModel with DataManager
    }
    
    var body: some View {
        ZStack {
            profileViewModel.selectedColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    // Button to toggle side menu visibility
                    Button {
                        presentSideMenu.toggle()
                    } label: {
                        Image(systemName: "list.bullet.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                
                // Pie chart view wrapped inside a custom view that takes the PieChartViewModel
                PieChartWrapper(viewModel: pieViewModel)
                    .frame(height: 300)
                    .padding(.horizontal)
                    .onAppear {
                        // Ensure the PieChartViewModel is aware of deleted categories on view appearance
                        pieViewModel.deletedCategories = expenseViewModel.deletedCategories
                        pieViewModel.updateChartData()  // Refresh the chart data
                    }
                
                // Navigation stack to handle list of categories and navigating to their details
                NavigationStack {
                    List {
                        ForEach(expenseViewModel.categoriesWithExpenses, id: \.self) { category in
                            NavigationLink(destination: {
                                let expenses = expenseViewModel.expenses(for: category)
                                let detailViewModel = DetailViewModel(expenses: expenses, dataManager: expenseViewModel.dataManager)
                                DetailView(viewModel: detailViewModel, categoryName: category)
                            }) {
                                Text(category)
                            }
                        }
                        .onDelete(perform: expenseViewModel.deleteCategory)
                    }
                    .navigationTitle("Categories")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                expenseViewModel.undoLastDelete()
                                print("Cancel button pressed")
                            }) {
                                Image(systemName: "arrow.uturn.right.circle.fill")
                                    .padding()
                                    .bold()
                                    .foregroundStyle(profileViewModel.selectedColor)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: expenseViewModel.shouldRefresh) {
            // Fetch updated categories and expenses when changes are detected
            expenseViewModel.fetchCategoriesWithExpenses()
            
            // Also update the PieChartViewModel when changes occur
            pieViewModel.deletedCategories = expenseViewModel.deletedCategories
            pieViewModel.updateChartData()  // Refresh pie chart data
        }
    }
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an in-memory NSPersistentContainer for preview purposes
        let container = NSPersistentContainer(name: "ExperimentApp")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")  // Use /dev/null for in-memory store
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load persistent stores: \(error)")
            }
        }

        // Initialize DataManager and ProfileViewModel with the preview context
        let context = container.viewContext
        let dataManager = DataManager(context: context)
        let profileViewModel = ProfileViewModel(context: context)
        
        return ExpenseView(presentSideMenu: .constant(false), dataManager: dataManager)
            .environmentObject(profileViewModel)  // Provide ProfileViewModel with context for the environment
    }
}

