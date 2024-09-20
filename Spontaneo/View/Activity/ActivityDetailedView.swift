//
//  ActivityDetailedView.swift
//  Spontaneo
//
//  Created by Bilhuda Pramana on 20/9/2024.
//

import SwiftUI
import MapKit

struct ActivityDetailedView: View {
    let activity: Activity
    @State private var showFullDescription = false
    @State private var showJoinConfirmation = false
    @State private var region: MKCoordinateRegion
    @State private var showChat = false
    @Environment(\.colorScheme) var colorScheme
    
    init(activity: Activity) {
        self.activity = activity
        _region = State(initialValue: MKCoordinateRegion(
            center: activity.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                
                contentSection
                
                joinButton
            }
            .padding(.bottom, 80) // Add extra padding at the bottom
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showChat = true }) {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
            }
        }
        .sheet(isPresented: $showChat) {
            ChatView(activity: activity)
        }
    }
    
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipped()
            
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .frame(height: 100)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Label(activity.host.name, systemImage: "person.circle")
                    Spacer()
                    Label(String(format: "%.1f", activity.host.rating), systemImage: "star.fill")
                }
                .font(.subheadline)
                .foregroundColor(.white)
            }
            .padding()
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            dateAndLocationSection
            
            descriptionSection
            
            participantsSection
            
            tagsSection
            
            mapSection
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
    
    private var dateAndLocationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(activity.date, style: .date)
                Text(" at ")
                Text(activity.date, style: .time)
            } icon: {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
            }
            
            Label {
                Text(activity.location.name)
            } icon: {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .font(.subheadline)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About this activity")
                .font(.headline)
            
            Text(activity.description)
                .lineLimit(showFullDescription ? nil : 3)
            
            Button(action: { showFullDescription.toggle() }) {
                Text(showFullDescription ? "Show less" : "Show more")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Participants")
                .font(.headline)
            
            HStack {
                ForEach(0..<min(5, activity.currentParticipants), id: \.self) { index in
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: CGFloat(index * -15))
                }
                
                if activity.currentParticipants > 5 {
                    Text("+\(activity.currentParticipants - 5)")
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                        .offset(x: CGFloat(-5 * 15))
                }
                
                Spacer()
                
                Text("\(activity.currentParticipants)/\(activity.maxParticipants)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var tagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(activity.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                }
            }
        }
    }
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)
            
            Map(coordinateRegion: $region, annotationItems: [activity]) { item in
                MapMarker(coordinate: item.location.coordinate)
            }
            .frame(height: 200)
            .cornerRadius(12)
        }
    }
    
    private var joinButton: some View {
        Button(action: { showJoinConfirmation = true }) {
            Text("Join Activity")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding()
        .alert(isPresented: $showJoinConfirmation) {
            Alert(
                title: Text("Join Activity"),
                message: Text("Are you sure you want to join this activity?"),
                primaryButton: .default(Text("Join")) {
                    // Action to join the activity
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ActivityDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ActivityDetailedView(activity: Activity.sampleActivity)
        }
    }
}
