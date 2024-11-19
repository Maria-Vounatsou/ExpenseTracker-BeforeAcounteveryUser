//
//  SignUpViewModel.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 13/11/24.
//

import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var signUpSuccessful: Bool = true
    @Published var showPassword: Bool = false // Add this property

    // Completion handler to be called upon successful sign-up
    var onSignUpSuccess: (() -> Void)?

    func signUp() {
        signUpSuccessful = DataManager.shared.signUpUser(email: email, password: password, username: username)
        if signUpSuccessful {
            print("User signed up and logged in.")
            onSignUpSuccess?() // Call the success handler if it's set
        } else {
            print("Sign-up failed. User may already exist.")
        }
    }
}



