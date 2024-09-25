import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    @State private var selectedTab = 0
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingSettings = false
    @State private var animateProfile = false
    
    init(userId: String) {
            _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
        }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileHeader
                
                CustomTabView(selectedTab: $selectedTab)
                    .padding(.top, 10)
                    .padding(.horizontal)
                
                tabContent
                
                Spacer(minLength: 50)
                
                signOutButton
                    .padding(.bottom, 100) // Increase bottom padding
            }
        }
        .edgesIgnoringSafeArea(.top)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0) // Add safe area inset at the bottom
        }
        .navigationBarHidden(true)
        .overlay(editProfileButton, alignment: .bottomTrailing)
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .overlay(loadingOverlay)
        .alert(item: Binding(
            get: { viewModel.errorMessage.map { ErrorWrapper(error: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { errorWrapper in
            Alert(title: Text("Error"), message: Text(errorWrapper.error))
        }
        .sheet(isPresented: $showingSettings) {
            SettingView()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                animateProfile = true
            }
        }
    }
    
    private var signOutButton: some View {
        Button(action: {
            authService.signOut()
        }) {
            Text("Sign Out")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("AccentColor"))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .transition(.move(edge: .bottom))
    }
    
    private var profileHeader: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color("SecondaryColor")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.top, 40)
                    .padding(.trailing, 20)
                }
                
                AsyncImage(url: viewModel.user.profileImageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                }
                .frame(width: 140, height: 140)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
                .overlay(
                    Image(systemName: "camera.circle.fill")
                        .foregroundColor(Color("AccentColor"))
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 50, y: 50)
                )
                .scaleEffect(animateProfile ? 1 : 0.5)
                .opacity(animateProfile ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.1), value: animateProfile)
                
                VStack(spacing: 4) {
                    Text(viewModel.user.fullName)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("@\(viewModel.user.username)")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(animateProfile ? 1 : 0)
                .offset(y: animateProfile ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: animateProfile)
                
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Label("Message", systemImage: "message.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button(action: {}) {
                        Label("Follow", systemImage: "person.badge.plus")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .opacity(animateProfile ? 1 : 0)
                .offset(y: animateProfile ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: animateProfile)
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
        .frame(height: 420)
    }
    
    private var tabContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(tabTitle)
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
                .padding(.horizontal)
                .padding(.top, 20)
            
            switch selectedTab {
            case 0:
                infoSection
            case 1:
                interestsSection
            case 2:
                activityHistorySection
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Info"
        case 1: return "Interests"
        case 2: return "Activity"
        default: return ""
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoRow(icon: "envelope.fill", title: "Email", value: viewModel.user.email)
            InfoRow(icon: "calendar", title: "Joined", value: viewModel.formattedJoinDate)
            InfoRow(icon: "text.quote", title: "Bio", value: viewModel.user.bio)
        }
        .padding(.horizontal)
    }
    
    private var interestsSection: some View {
        FlowLayout(alignment: .leading, spacing: 8) {
            ForEach(viewModel.user.interests, id: \.self) { interest in
                Text(interest)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("AccentColor").opacity(0.1))
                    .foregroundColor(Color("AccentColor"))
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal)
    }
    
    private var activityHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.user.activities.prefix(3), id: \.id) { activity in
                HStack {
                    Text(activity.title)
                        .font(.subheadline)
                    Spacer()
                    Text(formatDate(activity.date))
                        .font(.caption)
                        .foregroundColor(Color("NeutralDark"))
                }
                .padding(.vertical, 8)
            }
            
            NavigationLink(destination: Text("Activity History View")) {
                Text("See All")
                    .font(.subheadline)
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .padding(.horizontal)
    }
    
    private var editProfileButton: some View {
        Button(action: {
            showingEditProfile = true
        }) {
            HStack {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold))
                Text("Edit Profile")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color("SecondaryColor")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 100)
        .scaleEffect(animateProfile ? 1 : 0.5)
        .opacity(animateProfile ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.7), value: animateProfile)
    }
    
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CustomTabView: View {
    @Binding var selectedTab: Int
    let tabs = [
        ("Info", "info.circle"),
        ("Interests", "star"),
        ("Activity", "chart.bar")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].1)
                        Text(tabs[index].0)
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == index ? .white : Color("NeutralDark"))
                    .background(selectedTab == index ? Color("AccentColor") : Color.clear)
                    .cornerRadius(20)
                }
            }
        }
        .padding(4)
        .background(Color("NeutralLight"))
        .cornerRadius(25)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color("AccentColor"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Color("NeutralDark"))
                Text(value)
                    .font(.body)
                    .foregroundColor(Color("NeutralDark"))
            }
        }
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, alignment: alignment, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, alignment: alignment, spacing: spacing)
        for row in result.rows {
            for element in row.elements {
                element.place(element.point.applying(CGAffineTransform(translationX: bounds.minX, y: bounds.minY)))
            }
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var rows: [Row] = []

        struct Row {
            var elements: [Element] = []
            var frame: CGRect = .zero
        }

        struct Element {
            var point: CGPoint = .zero
            var size: CGSize = .zero
            var place: (CGPoint) -> Void = { _ in }
        }

        init(in width: CGFloat, subviews: Subviews, alignment: HorizontalAlignment, spacing: CGFloat) {
            var row = Row()
            var y: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if row.frame.width + size.width + spacing > width, !row.elements.isEmpty {
                    finalizeRow(width: width, alignment: alignment)
                    y += row.frame.height + spacing
                    row = Row()
                }

                row.elements.append(Element(size: size) { point in
                    subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
                })
                row.frame.size.width += size.width + spacing
                row.frame.size.height = max(row.frame.height, size.height)
            }

            if !row.elements.isEmpty {
                finalizeRow(width: width, alignment: alignment)
            }

            func finalizeRow(width: CGFloat, alignment: HorizontalAlignment) {
                let spacing = row.elements.count > 1 ? CGFloat(row.elements.count - 1) * spacing : 0
                let x = alignment == .leading ? 0 : (alignment == .trailing ? width - row.frame.width + spacing : (width - row.frame.width + spacing) / 2)
                var elementX = x

                for i in 0..<row.elements.count {
                    row.elements[i].point = CGPoint(x: elementX, y: y)
                    elementX += row.elements[i].size.width + spacing
                }

                rows.append(row)
                size.width = max(size.width, row.frame.width)
                size.height += row.frame.height + (rows.count > 1 ? spacing : 0)
            }
        }
    }
}

struct StandardSectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(height: 200)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color("NeutralLight"))
            .foregroundColor(Color("AccentColor"))
            .cornerRadius(20)
            .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userId: User.sampleUser.id)
    }
}
