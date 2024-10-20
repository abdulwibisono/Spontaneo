import SwiftUI

struct ChatView: View {
    @ObservedObject var chatService = ChatService()
    @EnvironmentObject var authService: AuthenticationService
    let activity: Activity
    @State private var newMessage: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(chatService.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(Color("AccentColor"))
                }
                .padding(.trailing)
            }
            .padding(.vertical)
        }
        .navigationTitle("Chat")
        .onAppear {
            if let currentUser = authService.user {
                chatService.listenForMessages(activityId: activity.id!, currentUserId: currentUser.id)
            }
        }
    }
    
    private func sendMessage() {
        guard let currentUser = authService.user, !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        chatService.sendMessage(activityId: activity.id!, text: newMessage, senderId: currentUser.id, senderName: currentUser.username)
        newMessage = ""
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
            }
            VStack(alignment: message.isCurrentUser ? .trailing : .leading) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(message.text)
                    .padding(10)
                    .background(message.isCurrentUser ? Color("AccentColor") : Color.gray.opacity(0.2))
                    .foregroundColor(message.isCurrentUser ? .white : Color("NeutralDark"))
                    .cornerRadius(10)
            }
            if !message.isCurrentUser {
                Spacer()
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleActivity = Activity(
            id: UUID().uuidString,
            title: "Sample Activity",
            category: "Coffee",
            date: Date(),
            location: Activity.Location(name: "Sample Location", latitude: 0, longitude: 0),
            currentParticipants: 1,
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
        return ChatView(activity: sampleActivity)
    }
}
