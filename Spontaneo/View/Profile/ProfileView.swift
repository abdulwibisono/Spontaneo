import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileHeader
                
                VStack(spacing: 20) {
                    infoSection
                    interestsSection
                    activityHistorySection
                    editProfileButton
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .offset(y: -30)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4))
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
        VStack(spacing: 20) {
            AsyncImage(url: viewModel.user.profileImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 160, height: 160)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)
            
            VStack(spacing: 8) {
                Text(viewModel.user.fullName)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("@\(viewModel.user.username)")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 30)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoRow(icon: "envelope.fill", title: "Email", value: viewModel.user.email)
            InfoRow(icon: "calendar", title: "Joined", value: viewModel.formattedJoinDate)
            InfoRow(icon: "text.quote", title: "Bio", value: viewModel.user.bio)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interests")
                .font(.headline)
                .foregroundColor(.secondary)
            
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(viewModel.user.interests, id: \.self) { interest in
                    Text(interest)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var activityHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(viewModel.user.activities.prefix(3), id: \.id) { activity in
                HStack {
                    Text(activity.title)
                        .font(.subheadline)
                    Spacer()
                    Text(formatDate(activity.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            NavigationLink(destination: Text("Activity History View")) {
                Text("See All")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
                .background(
                    LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(15)
                .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .padding(.top, 20)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
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
    var alignment: HorizontalAlignment = .center
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.sampleUser)
            
    }
}
