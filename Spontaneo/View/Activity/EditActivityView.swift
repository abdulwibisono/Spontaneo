import Foundation
import SwiftUI
import MapKit
import CoreLocation

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
    
    @State private var region: MKCoordinateRegion
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var isSearching = false
    @FocusState private var isLocationFieldFocused: Bool
    @StateObject private var searchCompleterDelegate = SearchCompleterDelegate()
    @State private var locationCoordinate: CLLocationCoordinate2D?
    @State private var isLocationValid: Bool = true
    
    init(activity: Activity) {
        _activity = State(initialValue: activity)
        _title = State(initialValue: activity.title)
        _description = State(initialValue: activity.description)
        _category = State(initialValue: activity.category)
        _date = State(initialValue: activity.date)
        _location = State(initialValue: activity.location.name)
        _maxParticipants = State(initialValue: activity.maxParticipants)
        _region = State(initialValue: MKCoordinateRegion(
            center: activity.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        _locationCoordinate = State(initialValue: activity.location.coordinate)
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
                        .focused($isLocationFieldFocused)
                        .onChange(of: location) { newValue in
                            if newValue.isEmpty {
                                searchResults = []
                                isSearching = false
                                isLocationValid = false
                                locationCoordinate = nil
                            } else {
                                searchCompleter.queryFragment = newValue
                                geocodeAddress(newValue)
                            }
                        }
                    if !isLocationValid && !location.isEmpty {
                        Text("Invalid location. Please enter a valid address.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    Map(coordinateRegion: $region, annotationItems: [SelectableLocation(coordinate: region.center)]) { item in
                        MapPin(coordinate: item.coordinate, tint: .red)
                    }
                    .frame(height: 200)
                    .cornerRadius(16)
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
        .onAppear {
            searchCompleter.delegate = searchCompleterDelegate
            searchCompleter.region = region
            searchCompleter.resultTypes = .address
            searchCompleterDelegate.bind(
                searchCompleter: searchCompleter,
                searchResults: $searchResults,
                isSearching: $isSearching,
                region: $region,
                onCompletionSelected: selectCompletion
            )
        }
        .overlay(
            VStack {
                if isSearching && !searchResults.isEmpty {
                    List(searchResults, id: \.self) { completion in
                        Button(action: {
                            selectCompletion(completion)
                        }) {
                            VStack(alignment: .leading) {
                                Text(completion.title)
                                    .font(.headline)
                                Text(completion.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: 200)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                }
            },
            alignment: .top
        )
    }
    
    private func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let placemark = response?.mapItems.first?.placemark else { return }
            self.location = placemark.title ?? ""
            self.region = MKCoordinateRegion(
                center: placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            self.locationCoordinate = placemark.coordinate
            self.isSearching = false
            self.searchResults = []
            self.isLocationFieldFocused = false
        }
    }
    
    private func geocodeAddress(_ address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                isLocationValid = false
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                isLocationValid = true
                locationCoordinate = location.coordinate
                region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            } else {
                isLocationValid = false
                locationCoordinate = nil
            }
        }
    }
    
    private func saveActivity() {
        guard isLocationValid, let coordinate = locationCoordinate else {
            print("Invalid location")
            return
        }

        let updatedActivity = Activity(
            id: activity.id,
            title: title,
            category: category,
            date: date,
            location: Activity.Location(
                name: location,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            currentParticipants: activity.currentParticipants,
            maxParticipants: maxParticipants,
            hostId: activity.hostId,
            hostName: activity.hostName,
            description: description,
            tags: activity.tags,
            receiveUpdates: activity.receiveUpdates,
            updates: activity.updates,
            rating: activity.rating
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