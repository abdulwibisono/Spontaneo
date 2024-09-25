import SwiftUI
import MapKit

struct ActivityDetailedView: View {
    let activity: Activity
    @State private var showFullDescription = false
    @State private var showJoinConfirmation = false
    @State private var region: MKCoordinateRegion
    @State private var showChat = false
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedImageIndex: Int = 0
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingEditActivity = false
    
    let placeholderImages = [
        "activity_placeholder",
        "activity_placeholder_2",
        "activity_placeholder_3"
    ]
    
    init(activity: Activity) {
        self.activity = activity
        _region = State(initialValue: MKCoordinateRegion(
            center: activity.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                
                VStack(alignment: .leading, spacing: 24) {
                    imagesSection
                    dateAndLocationSection
                    descriptionSection
                    participantsSection
                    tagsSection
                    mapSection
                    joinButton
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .background(Color("NeutralLight"))
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .offset(y: -30)
            }
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
                    Button(action: { showChat = true }) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
        }
        .sheet(isPresented: $showChat) {
            ChatView(activity: activity)
        }
        .sheet(isPresented: $showingEditActivity) {
            EditActivityView(activity: activity)
        }
    }
    
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image("activity_placeholder")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.clear, Color("NeutralDark").opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                )
            
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
                    Label(String(format: "%.1f", activity.rating), systemImage: "star.fill")
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
                ForEach(0..<placeholderImages.count, id: \.self) { index in
                    Image(placeholderImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                        .tag(index)
                }
            }
            .frame(height: 200)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
    
    private var dateAndLocationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                dateTimeInfo(title: "Date", icon: "calendar", value: activity.date, style: .date)
                dateTimeInfo(title: "Time", icon: "clock", value: activity.date, style: .time)
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                    .font(.title2)
                Text(activity.location.name)
                    .font(.headline)
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
            Label("Participants", systemImage: "person.3.fill")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            
            HStack {
                ForEach(0..<min(5, activity.currentParticipants), id: \.self) { index in
                    Image("user_placeholder")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("NeutralLight"), lineWidth: 2))
                        .offset(x: CGFloat(index * -15))
                }
                
                if activity.currentParticipants > 5 {
                    Text("+\(activity.currentParticipants - 5)")
                        .font(.subheadline)
                        .padding(8)
                        .background(Color("AccentColor"))
                        .foregroundColor(Color("NeutralLight"))
                        .clipShape(Circle())
                        .offset(x: CGFloat(-5 * 15))
                }
                
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
    
    private var joinButton: some View {
        Button(action: { showJoinConfirmation = true }) {
            Text("Join Activity")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color("SecondaryColor")]), startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(Color("NeutralLight"))
                .cornerRadius(16)
        }
        .padding(.vertical, 16)
        .shadow(color: Color("NeutralDark").opacity(0.2), radius: 10, x: 0, y: 5)
        .alert(isPresented: $showJoinConfirmation) {
            Alert(
                title: Text("Join Activity"),
                message: Text("Are you sure you want to join this activity?"),
                primaryButton: .default(Text("Join")) {
                    // Action to join the activity
                },
                secondaryButton: .cancel()
            )
        }
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
            description: "This is a sample activity for preview purposes.",
            tags: ["sample", "preview"],
            receiveUpdates: true,
            updates: [],
            rating: 4.5
        )
        
        return NavigationView {
            ActivityDetailedView(activity: sampleActivity)
        }
    }
}
