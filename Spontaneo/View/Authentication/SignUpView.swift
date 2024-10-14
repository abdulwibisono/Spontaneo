import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel: AuthenticationViewModel
    @EnvironmentObject var authService: AuthenticationService
    
    init(authService: AuthenticationService) {
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(authService: authService))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.white, .purple.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Text("🏃‍♀️ Sign Up!")
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                
                Text("Let's get you sorted")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                        TextField("Username", text: $viewModel.username)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.purple)
                        TextField("Email", text: $viewModel.email)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.purple)
                        SecureField("Password", text: $viewModel.password)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.signUp()
                }) {
                    Text("Sign up")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(10)
                        .shadow(color: .purple.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: LoginView(authService: authService)) {
                    Text("Already have an account? Sign in")
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                Text("Your adventure begins here! 🏁")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
