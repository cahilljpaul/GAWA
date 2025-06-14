import SwiftUI

// Add Color extension for maroon
extension Color {
    static let maroon = Color(red: 128/255, green: 0/255, blue: 0/255)
}

struct MyTeamView: View {
    @StateObject private var viewModel = MyTeamViewModel()
    @State private var selectedSport: Sport = .football
    @State private var showingTeamPicker = false
    @State private var searchText = ""
    
    var filteredTeams: [String] {
        let teams = viewModel.teams[selectedSport] ?? []
        if searchText.isEmpty {
            return teams
        }
        return teams.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading teams...")
                } else if let error = viewModel.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error loading teams")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                await viewModel.fetchTeams()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if viewModel.selectedTeam.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "sportscourt")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Team Selected")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("Select your favorite team to follow their matches")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button {
                            showingTeamPicker = true
                        } label: {
                            Label("Select Team", systemImage: "plus")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        // Sport selector
                        Picker("Sport", selection: $selectedSport) {
                            Text("Football").tag(Sport.football)
                            Text("Hurling").tag(Sport.hurling)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // Search bar
                        SearchBar(text: $searchText)
                            .padding(.horizontal)
                        
                        // Teams list
                        List {
                            ForEach(filteredTeams, id: \.self) { team in
                                TeamRow(team: team, isSelected: team == viewModel.selectedTeam) {
                                    viewModel.selectedTeam = team
                                    showingTeamPicker = false
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("My Team")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingTeamPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingTeamPicker) {
                NavigationView {
                    VStack(spacing: 0) {
                        SearchBar(text: $searchText)
                            .padding()
                        
                        List {
                            ForEach(filteredTeams, id: \.self) { team in
                                TeamRow(team: team, isSelected: team == viewModel.selectedTeam) {
                                    viewModel.selectedTeam = team
                                    showingTeamPicker = false
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                    .navigationTitle("Select Team")
                    .navigationBarItems(trailing: Button("Done") {
                        showingTeamPicker = false
                    })
                }
            }
        }
        .task {
            await viewModel.fetchTeams()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search teams", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct TeamRow: View {
    let team: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // County color indicator
                Circle()
                    .fill(teamColor(for: team))
                    .frame(width: 12, height: 12)
                
                Text(team)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func teamColor(for team: String) -> Color {
        switch team {
        case "Dublin": return .blue
        case "Kerry": return .green
        case "Mayo": return .red
        case "Tyrone": return .red
        case "Galway": return .maroon
        case "Donegal": return .green
        case "Cork": return .red
        case "Kilkenny": return .black
        case "Limerick": return .green
        case "Tipperary": return .blue
        case "Waterford": return .blue
        case "Clare": return .yellow
        case "Wexford": return .purple
        default: return .gray
        }
    }
}

class MyTeamViewModel: ObservableObject {
    @Published var teams: [Sport: [String]] = [:]
    @Published var selectedTeam: String {
        didSet {
            UserDefaults.standard.set(selectedTeam, forKey: "selectedTeam")
        }
    }
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        self.selectedTeam = UserDefaults.standard.string(forKey: "selectedTeam") ?? ""
    }
    
    func fetchTeams() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let url = URL(string: "http://localhost:5000/api/teams")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let teams = try JSONDecoder().decode([String: [String]].self, from: data)
            
            await MainActor.run {
                self.teams = [
                    .football: teams["football"] ?? [],
                    .hurling: teams["hurling"] ?? []
                ]
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
}

#Preview {
    MyTeamView()
} 