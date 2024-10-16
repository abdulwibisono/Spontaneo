import Foundation
import Firebase
import FirebaseFirestore

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let senderId: String
    let senderName: String
    let timestamp: Date
    var isCurrentUser: Bool = false
}

class ChatService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var messages: [Message] = []
    
    func sendMessage(activityId: String, text: String, senderId: String, senderName: String) {
        let message = Message(id: UUID().uuidString, text: text, senderId: senderId, senderName: senderName, timestamp: Date())
        
        do {
            try db.collection("activities").document(activityId).collection("messages").addDocument(from: message)
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    func listenForMessages(activityId: String, currentUserId: String) {
        db.collection("activities").document(activityId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.messages = documents.compactMap { document -> Message? in
                    do {
                        var message = try document.data(as: Message.self)
                        message.isCurrentUser = (message.senderId == currentUserId)
                        return message
                    } catch {
                        print("Error decoding message: \(error)")
                        return nil
                    }
                }
            }
    }
}
