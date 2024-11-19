//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 13/9/24.
//

import SwiftUI
import CoreData

@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared
    let context: NSManagedObjectContext

    @StateObject private var dataManager: DataManager
    @StateObject private var addAmountViewModel: AddAmountViewModel
    @StateObject private var profileViewModel = ProfileViewModel(context: PersistenceController.shared.container.viewContext)

    @AppStorage("isUserSignedIn") private var isUserSignedIn: Bool = false
    @State private var showSignInView = false // State to control SignIn/SignUp view

    init() {
        self.context = persistenceController.container.viewContext

        let manager = DataManager(context: context)
        _dataManager = StateObject(wrappedValue: manager)
        _addAmountViewModel = StateObject(wrappedValue: AddAmountViewModel(dataManager: manager))

        // Check Core Data for an existing signed-in user on launch
        self.isUserSignedIn = manager.isUserSignedInCoreData()
    }

    var body: some Scene {
        WindowGroup {
            if isUserSignedIn {
                MenuTabbedView(expenseService: dataManager, addAmountViewModel: addAmountViewModel)
                    .environment(\.managedObjectContext, context)
                    .environmentObject(dataManager)
                    .environmentObject(profileViewModel)
            } else {
                if showSignInView {
                    SignInView(
                        viewModel: SignInViewModel(dataManager: dataManager),
                        onSignInSuccess: {
                            self.isUserSignedIn = true // When sign-in is successful
                        },
                        onSignUpRequested: {
                            self.showSignInView = false // Navigate to SignUpView
                        }
                    )
                    .environmentObject(dataManager)
                } else {
                    SignUpView(
                        viewModel: SignUpViewModel(),
                        onSignInRequested: {
                            self.showSignInView = true // Navigate to SignInView
                        }
                    )
                    .environmentObject(dataManager)
                }
            }
        }
    }
}
