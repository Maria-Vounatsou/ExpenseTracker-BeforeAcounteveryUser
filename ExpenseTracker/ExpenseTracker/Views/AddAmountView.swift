//
//  SwiftUIView.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 9/9/24.
//

import SwiftUI

struct AddAmountView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @ObservedObject var viewModel: AddAmountViewModel
    @Binding var presentSideMenu: Bool
    @State private var isPressed = false
    @State private var showSheet = false
    
    var body: some View {
        ZStack {
            profileViewModel.selectedColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button {
                        presentSideMenu.toggle()
                    } label: {
                        Image(systemName: "list.bullet.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .accessibilityIdentifier("AddExpenseButton")
                    Spacer()
                }
                
                VStack {
                    NavigationView {
                        VStack {
                            HStack {
                                Spacer()
                                    .frame(width: 40, height: 80)
                                
                                TextField("", value: $viewModel.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    .font(.largeTitle)
                                    .keyboardType(.numberPad)  // Ensure number pad for easy input
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 200, height: 100)
                                    .accessibilityIdentifier("AmountTextField")
                                
                                // Display the currency symbol
                                Text(viewModel.currencySymbol)
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .overlay(
                                // Rounded border around the amount input field
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                                    .shadow(radius: 5, x: 5, y: 5)
                                    .padding(5)
                            )
                            .padding(10)
                            
                            Spacer()
                            Divider()
                            
                            Form {
                                Picker("Select Category", selection: $viewModel.selectedCategory) {
                                    ForEach(viewModel.categories, id: \.self) { category in
                                        Text(category)
                                            .bold()
                                    }
                                }
                                .accessibilityIdentifier("CategoryPicker")
                                .bold()
                                .foregroundColor(profileViewModel.selectedColor)
                                .onChange(of: viewModel.categories) {
                                    // Ensure selectedCategory is valid or set the first category
                                    if viewModel.selectedCategory.isEmpty || !viewModel.categories.contains(viewModel.selectedCategory) {
                                        viewModel.selectedCategory = viewModel.categories.first ?? ""  // Set the first category as default
                                    }
                                }
                                
                                HStack {
                                    Text("Edit Category")
                                        .foregroundStyle(profileViewModel.selectedColor)
                                        .bold()
                                    Spacer()
                                    Button(action: {
                                        showSheet = true
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                            .foregroundColor(profileViewModel.selectedColor)
                                    }
                                }
                                
                                Section(header:
                                            Text("Add Description")
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(profileViewModel.selectedColor)
                                ) {
                                    TextField("Description", text: $viewModel.expenseDescription)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .cornerRadius(30)
                                        .accessibilityIdentifier("DescriptionTextField")
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .navigationBarTitle("Add Amount", displayMode: .inline)
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            self.isPressed = true
                                        }
                                        
                                        // Perform the action
                                        viewModel.addExpenseAmount()
                                        
                                        // Reset the animation state after a delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                self.isPressed = false
                                            }
                                        }
                                    }) {
                                        Text("Save")
//                                            .font(.system(size: 23))
//                                            .bold()
//                                            .foregroundColor(.white)
//                                            .frame(width: 150, height: 50)  // Set a fixed frame for the button
//                                            .background(Color("ColorT"))
                                            .font(.system(size: 18, weight: .bold))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .foregroundColor(profileViewModel.selectedColor)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(profileViewModel.selectedColor, lineWidth: 1)
                                            )

                                    }
                                    .accessibilityIdentifier("SaveButton")
                                    .scaleEffect(isPressed ? 0.95 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isPressed)
                                    .shadow(radius: 5, x: 5, y: 5)
                                    
                                    Spacer()
                                }
                            }
                            .padding(30)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                // Present EditCategoryView when showSheet is true
                let viewModel = EditCategoryViewModel(dataManager: viewModel.dataManager)  // Reuse the same DataManager
                EditCategoryView(viewModel: viewModel)
            }
        }
    }
}

struct AddAmountView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let dataManager = DataManager(context: context)
        let viewModel = AddAmountViewModel(dataManager: dataManager)
        
        AddAmountView(viewModel: viewModel, presentSideMenu: .constant(false))
            .environmentObject(ProfileViewModel(context: context))
    }
}
