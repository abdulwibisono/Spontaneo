import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader
                infoSection
                interestsSection
                editProfileButton
            }
            .padding()
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        )
        .alert(item: Binding(
            get: { viewModel.errorMessage.map { ErrorWrapper(error: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { errorWrapper in
            Alert(title: Text("Error"), message: Text(errorWrapper.error))
        }
    }
    
    private var profileHeader: some View {
        VStack {
            AsyncImage(url: viewModel.user.profileImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            .shadow(radius: 5)
            
            Text(viewModel.user.fullName)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("@\(viewModel.user.username)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            InfoRow(icon: "envelope", title: "Email", value: viewModel.user.email)
            InfoRow(icon: "calendar", title: "Joined", value: viewModel.formattedJoinDate)
            InfoRow(icon: "text.quote", title: "Bio", value: viewModel.user.bio)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Interests")
                .font(.headline)
            
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(viewModel.user.interests, id: \.self) { interest in
                    Text(interest)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var editProfileButton: some View {
        Button(action: {
            showingEditProfile = true
        }) {
            Text("Edit Profile")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}

struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .center
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flowLayout(proposal.width ?? .infinity, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flowLayout(bounds.width, subviews: subviews)
        for (subview, position) in zip(subviews, result.positions) {
            subview.place(at: position, anchor: .topLeading, proposal: .unspecified)
        }
    }
    
    private func flowLayout(_ width: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var rowHeight: CGFloat = 0
        var rowWidth: CGFloat = 0
        var maxWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowStartIndex = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > width, !positions.isEmpty {
                let rowXOffset = alignmentOffset(for: rowWidth, in: width)
                for i in rowStartIndex..<index {
                    positions[i].x += rowXOffset
                }
                
                totalHeight += rowHeight + spacing
                rowStartIndex = index
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += (index == rowStartIndex ? 0 : spacing) + size.width
                rowHeight = max(rowHeight, size.height)
            }
            
            positions.append(CGPoint(x: rowWidth - size.width, y: totalHeight))
            maxWidth = max(maxWidth, rowWidth)
        }
        
        let rowXOffset = alignmentOffset(for: rowWidth, in: width)
        for i in rowStartIndex..<positions.count {
            positions[i].x += rowXOffset
        }
        
        totalHeight += rowHeight
        
        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
    
    private func alignmentOffset(for rowWidth: CGFloat, in containerWidth: CGFloat) -> CGFloat {
        switch alignment {
        case .leading:
            return 0
        case .center:
            return (containerWidth - rowWidth) / 2
        case .trailing:
            return containerWidth - rowWidth
        default:
            return 0
        }
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample user with mock data
        let sampleUser = User(
            username: "johndoe",
            email: "john@example.com",
            fullName: "John Doe",
            bio: "Software Developer with a passion for mobile apps.",
            profileImageURL: URL(string: "https://example.com/profile.jpg"),
            interests: ["Swift", "SwiftUI", "Combine"],
            joinDate: Date()
        )
        
        // Use the mock service for the preview
        let viewModel = ProfileViewModel(user: sampleUser, userService: MockUserService())
        
        return NavigationView {
            ProfileView(user: sampleUser)
        }
        .environmentObject(viewModel)
    }
}
