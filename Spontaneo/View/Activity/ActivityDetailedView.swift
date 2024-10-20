import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct ActivityDetailedView: View {
    @ObservedObject var activityService: ActivityService
        @EnvironmentObject var authService: AuthenticationService
        @State private var activity: Activity
        @State private var showFullDescription = false
        @State private var showJoinConfirmation = false
        @State private var showLeaveConfirmation = false
        @State private var region: MKCoordinateRegion
        @State private var showChat = false
        @State private var showJoinedUsersList = false
        @Environment(\.colorScheme) var colorScheme
        @State private var selectedImageIndex: Int = 0
        @State private var showingEditActivity = false
        @State private var isJoined = false
        @State private var showFireworks = false
    @State private var showingRatingSheet = false
    @State private var userRating: Double = 0
        @Environment(\.presentationMode) var presentationMode
        
        let placeholderImages = [
            "activity_placeholder",
            "activity_placeholder_2",
            "activity_placeholder_3"
        ]
        
    init(activity: Activity, activityService: ActivityService) {
        self._activity = State(initialValue: activity)
        self.activityService = activityService
        self._region = State(initialValue: MKCoordinateRegion(
            center: activity.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
        
        var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    VStack(alignment: .leading, spacing: 24) {
                        Button(action: {
                            showingRatingSheet = true
                        }) {
                            Text("Rate Host")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundColor(Color("NeutralLight"))
                                .cornerRadius(16)
                        }
                        .padding(.top)
                        .sheet(isPresented: $showingRatingSheet) {
                                    RatingView(rating: $userRating, onSubmit: submitRating)
                                }
                        imagesSection
                        dateAndLocationSection
                        descriptionSection
                        participantsSection
                        tagsSection
                        mapSection
                        buttonsSection
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .background(Color("NeutralLight"))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(y: -30)
                    .padding(.bottom, 36)
                }
                .overlay(
                                ZStack {
                                    if showFireworks {
                                        FireworkView()
                                            .frame(width: 400, height: 400)
                                            .transition(.opacity)
                                            .zIndex(1)
                                    }
                                }
                            )
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if activity.hostId == authService.user?.id {
                            Button(action: { showingEditActivity = true }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                        if isJoined {
                            Button(action: { showChat = true }) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showChat) {
                ChatView(activity: activity)
                    .environmentObject(authService)
            }
            .sheet(isPresented: $showingEditActivity) {
                EditActivityView(activity: activity)
            }
            .sheet(isPresented: $showJoinedUsersList) {
                JoinedUsersListView(joinedUsers: activity.joinedUsers)
            }
            .onAppear {
                checkIfUserJoined()
            }
        }
    
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let firstImageUrl = activity.imageUrls.first {
                AsyncImage(url: firstImageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .overlay(
                                    Color.black
                                        .opacity(0.5)
                                )
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(activity.category)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("AccentColor").opacity(0.2))
                    .foregroundColor(Color("AccentColor"))
                    .clipShape(Capsule())
                
                Text(activity.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("NeutralLight"))
                
                HStack {
                                Label(activity.hostName, systemImage: "person.circle.fill")
                                Spacer()
                                if let hostRating = activity.hostRating {
                                    Label(String(format: "%.1f", hostRating), systemImage: "star.fill")
                                }
                            }
                .font(.subheadline)
                .foregroundColor(Color("NeutralLight").opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
    }
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Photos", systemImage: "photo.on.rectangle.angled")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            
            TabView(selection: $selectedImageIndex) {
                ForEach(activity.imageUrls, id: \.self) { url in
                    WebImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                }
            }
            .frame(height: 200)
            .tabViewStyle(PageTabViewStyle())
        }
    }
    
    private var dateAndLocationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                dateTimeInfo(title: "Date", icon: "calendar", value: activity.date, style: .date)
                Spacer()
                dateTimeInfo(title: "Time", icon: "clock", value: activity.date, style: .time)
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                    .font(.title2)
                Text(activity.location.name)
                    .font(.system(size: 16))
                    .foregroundColor(Color("NeutralDark"))
            }
        }
        .padding()
        .background(Color("NeutralLight"))
        .cornerRadius(16)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func dateTimeInfo(title: String, icon: String, value: Date, style: Text.DateStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundColor(Color("NeutralDark").opacity(0.6))
            Text(value, style: style)
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Description", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            
            Text(activity.description)
                .lineLimit(showFullDescription ? nil : 3)
                .font(.subheadline)
                .foregroundColor(Color("NeutralDark").opacity(0.8))
            
            Button(action: { showFullDescription.toggle() }) {
                Text(showFullDescription ? "Show less" : "Show more")
                    .font(.subheadline)
                    .foregroundColor(Color("AccentColor"))
            }
        }
    }
    
    private var participantsSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Participants", systemImage: "person.3.fill")
                        .font(.headline)
                        .foregroundColor(Color("NeutralDark"))
                    
                    Spacer()
                    
                    Text("\(activity.currentParticipants)/\(activity.maxParticipants)")
                        .font(.headline)
                        .foregroundColor(Color("NeutralDark"))
                }
                
            }
            .padding()
            .background(Color("NeutralLight"))
            .cornerRadius(16)
            .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
        }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tags", systemImage: "tag.fill")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(activity.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("AccentColor").opacity(0.1))
                            .foregroundColor(Color("AccentColor"))
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Location", systemImage: "map")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            
            Map(coordinateRegion: $region, annotationItems: [activity]) { item in
                MapAnnotation(coordinate: item.location.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(Color("AccentColor"))
                        .font(.title)
                        .background(Circle().fill(Color("NeutralLight")))
                        .clipShape(Circle())
                }
            }
            .frame(height: 200)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("NeutralLight"), lineWidth: 1)
            )
            .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    private var buttonsSection: some View {
            VStack(spacing: 8) {
                joinLeaveButton
                viewJoinedUsersButton
            }
        }

    private var joinLeaveButton: some View {
            Group {
                if let currentUser = authService.user {
                    if activity.hostId != currentUser.id {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                                isJoined.toggle()
                            }
                            if !isJoined {
                                leaveActivity()
                            } else {
                                joinActivity()
                                showFireworks = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showFireworks = false
                                    }
                                }
                            }
                        }) {
                            Text(isJoined ? "Leave Activity" : "Join Activity")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isJoined ? Color.red : Color("AccentColor"))
                                .foregroundColor(Color("NeutralLight"))
                                .cornerRadius(16)
                        }
                        .scaleEffect(isJoined ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isJoined)
                    }
                }
            }
        }
        
        private var viewJoinedUsersButton: some View {
            Button(action: { showJoinedUsersList = true }) {
                Text("View Joined Users")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color("NeutralLight"))
                    .cornerRadius(16)
            }
        }
        
    private func checkIfUserJoined() {
            if let currentUser = authService.user {
                isJoined = activity.joinedUsers.contains { $0.id == currentUser.id }
            }
        }
        
    private func joinActivity() {
        guard let currentUser = authService.user else { return }
        
        Task {
            do {
                try await activityService.joinActivity(activityId: activity.id!, user: currentUser)
                refreshActivity()
            } catch {
                print("Error joining activity: \(error.localizedDescription)")
            }
        }
    }

    private func leaveActivity() {
        guard let currentUser = authService.user else { return }
        
        Task {
            do {
                try await activityService.leaveActivity(activityId: activity.id!, userId: currentUser.id)
                refreshActivity()
            } catch {
                print("Error leaving activity: \(error.localizedDescription)")
            }
        }
    }
            
    private func refreshActivity() {
        Task {
            await activityService.getActivity(id: activity.id!) { updatedActivity in
                if let updatedActivity = updatedActivity {
                    DispatchQueue.main.async {
                        self.activity = updatedActivity
                        self.checkIfUserJoined()
                    }
                }
            }
        }
    }
    
    private func submitRating() {
            authService.rateUser(userId: activity.hostId, rating: userRating)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Rating submitted successfully")
                    case .failure(let error):
                        print("Error submitting rating: \(error.localizedDescription)")
                    }
                }, receiveValue: { _ in
                    showingRatingSheet = false
                })
        }
}

struct ActivityDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleActivity = Activity(
            id: UUID().uuidString,
            title: "Sample Activity",
            category: "Coffee",
            date: Date(),
            location: Activity.Location(name: "Sample Location", latitude: -27.4698, longitude: 153.0251),
            currentParticipants: 5,
            maxParticipants: 10,
            hostId: "sampleHostId",
            hostName: "Sample Host",
            hostRating: 4.5,
            description: "This is a sample activity for preview purposes.",
            tags: ["sample", "preview"],
            receiveUpdates: true,
            updates: [],
            rating: 4.5,
            joinedUsers: [Activity.JoinedUser(id: "1", username: "User1", fullName: "FullName")],
            imageUrls: []
        )
        
        return NavigationView {
            ActivityDetailedView(activity: sampleActivity, activityService: ActivityService())
                .environmentObject(AuthenticationService())
        }
    }
}

struct RatingView: View {
    @Binding var rating: Double
    var onSubmit: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Rate the Host")
                .font(.title)
                .fontWeight(.bold)

            HStack {
                ForEach(1...5, id: \.self) { number in
                    Image(systemName: number <= Int(rating) ? "star.fill" : "star")
                        .foregroundColor(Color("AccentColor"))
                        .font(.largeTitle)
                        .onTapGesture {
                            rating = Double(number)
                        }
                }
            }

            Button(action: {
                onSubmit()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Submit Rating")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(Color("NeutralLight"))
                    .cornerRadius(16)
            }
        }
        .padding()
    }
}