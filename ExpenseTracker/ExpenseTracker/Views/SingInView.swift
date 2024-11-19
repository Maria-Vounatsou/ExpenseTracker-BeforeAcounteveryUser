//
//  SingInView.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 15/11/24.
//

import SwiftUI

struct SignInView: View {
    @ObservedObject var viewModel: SignInViewModel
    var onSignInSuccess: () -> Void
    var onSignUpRequested: () -> Void
    
    var body: some View {
        ZStack {
            Color.new.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("ExpenseTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                CustomTextField(placeholder: "Email", text: $viewModel.email)
                
                ZStack {
                    if viewModel.showPassword {
                        CustomTextField(placeholder: "Password", text: $viewModel.password)
                    } else {
                        CustomSecureField(placeholder: "Password", text: $viewModel.password)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.showPassword.toggle()
                        }) {
                            Image(systemName: viewModel.showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 25)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.signIn()
                    if viewModel.signInSuccessful {
                        onSignInSuccess() // Call success closure on successful sign-in
                    }
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(30)
                }
                .padding(.top, 20)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: onSignUpRequested) { // Call sign-up requested closure
                        Text("Sign up")
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Sign-In Failed"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.errorMessage = nil
                    }
                )
            }
        }
    }
}



// Mock SignInViewModel for Preview
class MockSignInViewModel: SignInViewModel {
    init() {
        let context = PersistenceController.preview.container.viewContext
        let dataManager = DataManager(context: context)
        super.init(dataManager: dataManager)
        self.email = "example@example.com"
        self.password = "password"
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of the mock view model
        let mockViewModel = MockSignInViewModel()

        Group {
            // Light mode preview
            SignInView(
                viewModel: mockViewModel,
                onSignInSuccess: {},
                onSignUpRequested: {}
            )
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .light)
            .previewDisplayName("Light Mode")
            
            // Dark mode preview
            SignInView(
                viewModel: mockViewModel,
                onSignInSuccess: {},
                onSignUpRequested: {}
            )
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
