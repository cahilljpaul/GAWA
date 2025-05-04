import SwiftUI

struct ContentView: View {
    @State private var matches: [Match] = []
    @AppStorage("followedSport") var followedSport: String = "Football"
    @AppStorage("followedTeam") var followedTeam: String = "Dublin"

    let refreshTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Select Team", destination: TeamSelectorView())
                    .padding(.bottom)

                NavigationLink("See All Matches", destination: AllMatchesView())
                    .padding(.bottom)

                List(filteredMatches) { match in
                    HStack {
                        AsyncImage(url: URL(string: match.homeLogo)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)

                        VStack(alignment: .leading) {
                            Text("\(match.homeTeam) vs \(match.awayTeam)")
                                .font(.headline)
                            Text("Score: \(match.homeScore) - \(match.awayScore)")
                            Text("Kickoff: \(match.time) @ \(match.venue)")
                                .font(.caption)
                            Text("Date: \(match.date)")
                                .font(.caption2)

                            if match.status == "Live" {
                                Text("LIVE")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .bold()
                            } else {
                                Text("Status: \(match.status)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }

                        AsyncImage(url: URL(string: match.awayLogo)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                    }
                }
                .navigationTitle("My Team")
                .onAppear { loadMatches() }
                .onReceive(refreshTimer) { _ in loadMatches() }
            }
        }
    }

    var filteredMatches: [Match] {
        matches.filter {
            $0.sport == followedSport &&
            ($0.homeTeam == followedTeam || $0.awayTeam == followedTeam)
        }
    }

    func loadMatches() {
        guard let url = URL(string: "http://127.0.0.1:5000/matches") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Match].self, from: data) {
                DispatchQueue.main.async {
                    matches = decoded
                }
            }
        }.resume()
    }
}
