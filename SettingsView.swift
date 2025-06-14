import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("refreshInterval") private var refreshInterval = 30
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    let refreshIntervals = [15, 30, 60, 120] // in seconds
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    if notificationsEnabled {
                        Text("You'll receive notifications for your team's matches")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Data Refresh")) {
                    Picker("Refresh Interval", selection: $refreshInterval) {
                        ForEach(refreshIntervals, id: \.self) { interval in
                            Text("\(interval) seconds")
                        }
                    }
                    Text("How often the app checks for new match data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://www.gaa.ie")!) {
                        HStack {
                            Text("GAA Website")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
} 