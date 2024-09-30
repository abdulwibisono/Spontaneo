import Foundation
import SwiftUI

struct EditActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var activityService = ActivityService()
    @State private var activity: Activity
    @State private var title: String
    @State private var description: String
    @State private var category: String
    @State private var date: Date
    @State private var location: String
    @State private var maxParticipants: Int
    
    init(activity: Activity) {
        _activity = State(initialValue: activity)
        _title = State(initialValue: activity.title)
        _description = State(initialValue: activity.description)
        _category = State(initialValue: activity.category)
        _date = State(initialValue: activity.date)
        _location = State(initialValue: activity.location.name)
        _maxParticipants = State(initialValue: activity.maxParticipants)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(["Coffee", "Study", "Sports", "Food", "Explore"], id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Date and Time")) {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Location")) {
                    TextField("Location", text: $location)
                }
                
                Section(header: Text("Participants")) {
                    Stepper("Max Participants: \(maxParticipants)", value: $maxParticipants, in: 2...100)
                }
            }
            .navigationTitle("Edit Activity")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveActivity()
                }
            )
        }
    }
    
    private func saveActivity() {
        let updatedActivity = Activity(
            id: activity.id,
            title: title,
            category: category,
            date: date,
            location: Activity.Location(name: location, latitude: activity.location.latitude, longitude: activity.location.longitude),
            currentParticipants: activity.currentParticipants,
            maxParticipants: maxParticipants,
            hostId: activity.hostId,
            hostName: activity.hostName,
            description: description,
            tags: activity.tags,
            receiveUpdates: activity.receiveUpdates,
            updates: activity.updates,
            rating: activity.rating,
            joinedUsers: activity.joinedUsers
        )
        
        activityService.updateActivity(updatedActivity) { result in
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error updating activity: \(error.localizedDescription)")
            }
        }
    }
}
