//
//  SettingView.swift
//  Spontaneo
//
//  Created by Bilhuda Pramana on 14/9/2024.
//

import SwiftUI

struct SettingView: View {
    @State private var receiveNotifications = true
    @State private var darkModeEnabled = false
    @State private var useLocationServices = true
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Edit Profile")) {
                        SettingsRow(title: "Edit Profile", icon: "person.circle")
                    }
                    NavigationLink(destination: Text("Change Password")) {
                        SettingsRow(title: "Change Password", icon: "lock")
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Receive Notifications", isOn: $receiveNotifications)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Section(header: Text("Privacy")) {
                    Toggle("Location Services", isOn: $useLocationServices)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    NavigationLink(destination: Text("Privacy Policy")) {
                        SettingsRow(title: "Privacy Policy", icon: "hand.raised")
                    }
                }
                
                Section {
                    Button(action: {
                        // Implement logout functionality
                        print("Logout tapped")
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(title)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}