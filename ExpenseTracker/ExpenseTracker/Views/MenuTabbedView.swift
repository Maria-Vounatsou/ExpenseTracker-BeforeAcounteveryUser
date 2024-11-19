//
//  MainTabbedView.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 9/9/24.
//

import SwiftUI
import CoreData

struct MenuTabbedView: View {
    
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var expenseService: DataManager
    @ObservedObject var addAmountViewModel: AddAmountViewModel
  
    var body: some View {
        ZStack {
            TabView(selection: $selectedSideMenuTab) {
                ExpenseView(presentSideMenu: $presentSideMenu, dataManager: expenseService)
                    .tag(0)
                ProfileView(presentSideMenu: $presentSideMenu)
                    .tag(2)
                AddAmountView( viewModel: addAmountViewModel,presentSideMenu: $presentSideMenu) 
                    .tag(1)
            }
            SideMenu(isShowing: $presentSideMenu, content: AnyView(SideMenuView(selectedSideMenuTab: $selectedSideMenuTab, presentSideMenu: $presentSideMenu)))
        }
    }
}

struct MenuTabbedView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview managed object context
        let context = PersistenceController.preview.container.viewContext
        
        // Initialize DataManager with the context
        let dataManager = DataManager(context: context)
        
        // Initialize AddAmountViewModel with DataManager
        let addAmountViewModel = AddAmountViewModel(dataManager: dataManager)
        
        // Initialize MenuTabbedView with dependencies
        MenuTabbedView(expenseService: dataManager, addAmountViewModel: addAmountViewModel)
            .environment(\.managedObjectContext, context)  // Set the environment context
            .environmentObject(ProfileViewModel(context: context)) // Set environment object if needed
    }
}

