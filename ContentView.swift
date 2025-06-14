import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var matches: [Match] = []
    @AppStorage("followedSport") var followedSport: Sport = .football
    @AppStorage("followedTeam") var followedTeam: String = "Dublin"
    @State private var isLoading = false
    @State private var error: Error?
    @State private var selectedTab = 0

    let refreshTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $selectedTab) {
            AllMatchesView()
                .tabItem {
                    Label("Matches", systemImage: "sportscourt")
                }
                .tag(0)
            
            MyTeamView()
                .tabItem {
                    Label("My Team", systemImage: "person")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }

    var filteredMatches: [Match] {
        matches.filter {
            $0.sport == followedSport &&
            ($0.homeTeam == followedTeam || $0.awayTeam == followedTeam)
        }
    }

    func loadMatches() {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "http://127.0.0.1:5000/api/v1/matches") else {
            error = URLError(.badURL)
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                guard let data = data else {
                    self.error = URLError(.cannotParseResponse)
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(MatchResponse.self, from: data)
                    self.matches = response.data
                } catch {
                    self.error = error
                }
            }
        }.resume()
    }

    func loadFollowedTeam(completion: @escaping (String, String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let sport = data["followedSport"] as? String,
               let team = data["followedTeam"] as? String {
                completion(sport, team)
            }
        }
    }
}

#Preview {
    ContentView()
}
