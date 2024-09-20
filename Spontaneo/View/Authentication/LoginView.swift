import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: AuthenticationViewModel
    @EnvironmentObject var authService: AuthenticationService
    
    init(authService: AuthenticationService) {
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(authService: authService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, .blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Text("🏃‍♂️ Spontaneo")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Let's jump in!")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                            TextField("Email", text: $viewModel.email)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.blue)
                            SecureField("Password", text: $viewModel.password)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Sign in")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: SignUpView(authService: authService)) {
                        Text("New here? Sign up!")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Ready, set, go! 🎉")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
