import SwiftUI

struct JoinedUsersListView: View {
    let joinedUsers: [Activity.JoinedUser]
    
    var body: some View {
        List(joinedUsers) { user in
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                Text(user.username)
                    .font(.headline)
            }
        }
        .navigationTitle("Joined Users")
    }
}

struct JoinedUsersListView_Previews: PreviewProvider {
    static var previews: some View {
        JoinedUsersListView(joinedUsers: [
            Activity.JoinedUser(id: "1", username: "User1"),
            Activity.JoinedUser(id: "2", username: "User2"),
            Activity.JoinedUser(id: "3", username: "User3")
        ])
    }
}
