import SwiftUI
import MapKit

struct ActivityView: View {
    var activity: Activity
    @State private var region: MKCoordinateRegion
    @State private var isJoined = false
    @State private var showChat = false
    @State private var showInviteFriends = false
    @State private var receiveUpdates: Bool

    init(activity: Activity) {
        self.activity = activity
        _region = State(initialValue: MKCoordinateRegion(
            center: activity.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        _receiveUpdates = State(initialValue: activity.receiveUpdates)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Basic Information
                Text(activity.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(activity.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(activity.date, style: .date)
                Text(activity.date, style: .time)
                Map(coordinateRegion: $region)
                    .frame(height: 200)
                    .cornerRadius(10)
                Text("Participants: \(activity.currentParticipants)/\(activity.maxParticipants)")
                HStack {
                    Image(systemName: "person.circle")
                    Text(activity.host.name)
                    Spacer()
                    Text("Rating: \(activity.host.rating)")
                }

                // Description
                Text(activity.description)
                    .font(.body)
                ForEach(activity.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                // Participant Management
                HStack {
                    Button(action: {
                        isJoined.toggle()
                    }) {
                        Text(isJoined ? "Leave" : "Join")
                            .padding()
                            .background(isJoined ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        showInviteFriends.toggle()
                    }) {
                        Text("Invite Friends")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .sheet(isPresented: $showInviteFriends) {
                    InviteFriendsView()
                }

                // Real-time Chat
                Button(action: {
                    showChat.toggle()
                }) {
                    Text("Open Chat")
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showChat) {
                    ChatView(activity: activity)
                }

                // Activity Updates
                Text("Activity Updates")
                    .font(.headline)
                ForEach(activity.updates, id: \.self) { update in
                    Text(update)
                        .font(.body)
                }
                Toggle("Receive Updates", isOn: $receiveUpdates)

                // Related Activities
                Text("Related Activities")
                    .font(.headline)
                ForEach(activity.relatedActivities, id: \.self) { relatedActivity in
                    Text(relatedActivity.title)
                        .font(.body)
                }

                // Feedback and Reporting
                if activity.date < Date() {
                    Button(action: {
                        // Rate and review action
                    }) {
                        Text("Rate and Review")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                Button(action: {
                    // Report action
                }) {
                    Text("Report Activity")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    // Suggest edits action
                }) {
                    Text("Suggest Edits")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarTitle("Activity Details", displayMode: .inline)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activity: Activity.sampleActivity)
    }
}
