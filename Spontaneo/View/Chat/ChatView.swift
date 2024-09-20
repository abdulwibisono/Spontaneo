import SwiftUI

struct ChatView: View {
    var activity: Activity
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""

    var body: some View {
        VStack {
            List(messages) { message in
                HStack {
                    if message.isCurrentUser {
                        Spacer()
                        Text(message.text)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text(message.text)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            HStack {
                TextField("Type a message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    sendMessage()
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
    }

    private func sendMessage() {
        let message = Message(id: UUID(), text: newMessage, isCurrentUser: true)
        messages.append(message)
        newMessage = ""
    }
}

struct Message: Identifiable {
    let id: UUID
    let text: String
    let isCurrentUser: Bool
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(activity: Activity.sampleActivity)
    }
}
