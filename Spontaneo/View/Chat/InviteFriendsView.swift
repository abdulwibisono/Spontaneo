import SwiftUI

struct InviteFriendsView: View {
    @State private var friends = ["Alice", "Bob", "Charlie", "David"]
    @State private var selectedFriends = Set<String>()

    var body: some View {
        NavigationView {
            List(friends, id: \.self, selection: $selectedFriends) { friend in
                Text(friend)
            }
            .navigationTitle("Invite Friends")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Invite") {
                        // Handle invite action
                    }
                }
            }
        }
    }
}

struct InviteFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        InviteFriendsView()
    }
}
