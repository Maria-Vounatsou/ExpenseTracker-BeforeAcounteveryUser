//
//  SignInViewModel.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 15/11/24.
//

import SwiftUI
import Combine

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showPassword: Bool = false
    @Published var signInSuccessful: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let dataManager: DataManager // Assuming you have a data manager for authentication
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in both fields."
            print("Sign-in failed: Fields are empty.")
            return
        }

        print("Attempting to authenticate - Email: \(email), Password: \(password)")
        if dataManager.authenticateUser(email: email, password: password) {
            signInSuccessful = true
            errorMessage = nil
            print("Sign-in successful.")
        } else {
            signInSuccessful = false
            errorMessage = "Invalid email or password."
            print("Sign-in failed: Invalid email or password.")
        }
    }
}

