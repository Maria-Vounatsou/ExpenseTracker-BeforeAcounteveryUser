//
//  EditCategoryView.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 24/9/24.
//

import SwiftUI
import CoreData

struct EditCategoryView: View {
    @ObservedObject var viewModel: EditCategoryViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                profileViewModel.selectedColor
                    .frame(height: 90)
                    .edgesIgnoringSafeArea(.top)
                
                Spacer()
            }
            VStack {
                Spacer()
                
                Text("Edit Category")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top,100)
                
                Form {
                    Section(header: Text("Add Category")
                        .bold()
                        .font(.title3)
                        .foregroundColor(profileViewModel.selectedColor)
                    ) {
                        HStack {
                            TextField("Add New Category", text: $viewModel.addCategory)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(30)
                            
                            Button(action: {
                                viewModel.addCategoryAction()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                            }
                        }
                    }
                    
                    Section(header: Text("Delete Category")
                        .bold()
                        .font(.title3)
                        .foregroundColor(profileViewModel.selectedColor)
                    ) {
                        HStack {
                            TextField("Permanent Deletion", text: $viewModel.deleteCategory)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(30)
                            
                            Button(action: {
                                viewModel.deleteCategoryAction()
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 10)
                }
                .scrollContentBackground(.hidden)
                .padding(.top, 10)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            switch viewModel.alertType {
            case .deleteConfirmation:
                return Alert(
                    title: Text("Delete Category"),
                    message: Text(viewModel.alertMessage),
                    primaryButton: .destructive(Text("OK"), action: {
                        viewModel.confirmDeleteCategory()
                    }),
                    secondaryButton: .cancel()
                )
            case .categoryIssue:
                return Alert(
                    title: Text("Category Issue"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            case .none:
                return Alert(title: Text("Unexpected Alert"))  // Fallback alert in case of an error
            }
        }
    }
}

struct EditCategoryView_Previews: PreviewProvider {
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
        let viewModel = EditCategoryViewModel(dataManager: dataManager)

        return EditCategoryView(viewModel: viewModel)
            .environmentObject(profileViewModel)  // Provide ProfileViewModel with context for the environment
            .environment(\.managedObjectContext, context)
    }
}


