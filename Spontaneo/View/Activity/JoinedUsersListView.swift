import SwiftUI

struct JoinedUsersListView: View {
    let joinedUsers: [Activity.JoinedUser]
    
    var body: some View {
        List {
            ForEach(joinedUsers) { user in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .font(.headline)
                        Text(user.fullName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .padding(.top, 30)
    }
}

struct JoinedUsersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JoinedUsersListView(joinedUsers: [
                Activity.JoinedUser(id: "1", username: "user1", fullName: "John Doe"),
                Activity.JoinedUser(id: "2", username: "user2", fullName: "Jane Smith"),
                Activity.JoinedUser(id: "3", username: "user3", fullName: "Bob Johnson")
            ])
        }
    }
}
