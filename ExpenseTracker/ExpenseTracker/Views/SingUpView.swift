
import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    var onSignInRequested: () -> Void // Closure for navigating to SignInView

    var body: some View {
        ZStack {
            Color.new.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("ExpenseTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                CustomTextField(placeholder: "Username", text: $viewModel.username)
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
                    viewModel.signUp()
                }) {
                    Text("Sign Up")
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
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: onSignInRequested) { // Call sign-in requested closure
                        Text("Sign in")
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        // Add the alert modifier here
        .alert(isPresented: .constant(!viewModel.signUpSuccessful)) {
            Alert(
                title: Text("Sign-Up Failed"),
                message: Text("User may already exist."),
                dismissButton: .default(Text("OK")) {
                    // Reset signUpSuccessful to true after dismissing
                    viewModel.signUpSuccessful = true
                }
            )
        }
    }
}

// CustomTextField with centered placeholder
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(1)) // Placeholder color
                    .padding(.leading, 24) // Adjust horizontal padding
                    .padding(.vertical, 12) // Adjust vertical padding for centering
            }
            
            TextField("", text: $text)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .foregroundColor(.white) // Entered text color
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 3)
                )
                .autocapitalization(.none)
                .padding(.horizontal)
        }
    }
}

// CustomSecureField with centered placeholder
struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(1)) // Placeholder color
                    .padding(.leading, 24) // Adjust horizontal padding
                    .padding(.vertical, 12) // Adjust vertical padding for centering
            }
            
            SecureField("", text: $text)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .foregroundColor(.white) // Entered text color
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 3)
                )
                .autocapitalization(.none)
                .padding(.horizontal)
        }
    }
}

// Mock SignUpViewModel for preview
class MockSignUpViewModel: SignUpViewModel {
    override init() {
        super.init()
        self.email = "example@example.com"
        self.username = "PreviewUser"
        self.password = "password"
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of the mock view model
        let mockViewModel = MockSignUpViewModel()

        // Pass the mock view model and a placeholder closure for `onSignInRequested`
        Group {
            SignUpView(viewModel: mockViewModel, onSignInRequested: {
                // Placeholder action for preview
                print("Navigate to SignInView")
            })
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .light) // Light mode preview
            
            SignUpView(viewModel: mockViewModel, onSignInRequested: {
                // Placeholder action for preview
                print("Navigate to SignInView")
            })
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .dark) // Dark mode preview
        }
    }
}



