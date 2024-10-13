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
