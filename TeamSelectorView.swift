import SwiftUI

struct TeamSelectorView: View {
    let sports = ["Football", "Hurling", "Camogie"]
    let teamsBySport = [
        "Football": ["Dublin", "Kerry", "Mayo", "Armagh"],
        "Hurling": ["Antrim", "Cork", "Kilkenny"],
        "Camogie": ["Galway", "Tipperary", "Clare"]
    ]

    @AppStorage("followedSport") var followedSport: String = "Football"
    @AppStorage("followedTeam") var followedTeam: String = "Dublin"

    var body: some View {
        Form {
            Picker("Sport", selection: $followedSport) {
                ForEach(sports, id: \.self) { sport in
                    Text(sport)
                }
            }

            if let teams = teamsBySport[followedSport] {
                Picker("Team", selection: $followedTeam) {
                    ForEach(teams, id: \.self) { team in
                        Text(team)
                    }
                }
            }
        }
        .navigationTitle("Follow a Team")
    }
}
