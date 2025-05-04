import SwiftUI

enum MatchDay: String, CaseIterable {
    case yesterday = "Yesterday"
    case today = "Today"
    case tomorrow = "Tomorrow"
}

struct AllMatchesView: View {
    @State private var selectedDay: MatchDay = .today
    @State private var matches: [Match] = []

    let refreshTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Picker("Select Day", selection: $selectedDay) {
                ForEach(MatchDay.allCases, id: \.self) { day in
                    Text(day.rawValue).tag(day)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List(filteredMatches) { match in
                HStack {
                    AsyncImage(url: URL(string: match.homeLogo)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 30, height: 30)

                    VStack(alignment: .leading) {
                        Text("\(match.homeTeam) vs \(match.awayTeam)")
                            .font(.headline)

                        Text("Score: \(match.homeScore) - \(match.awayScore)")
                            .font(.subheadline)

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

                        Text("Kickoff: \(match.time)")
                            .font(.caption2)

                        Text("Date: \(match.date)")
                            .font(.caption2)

                        Text("Venue: \(match.venue)")
                            .font(.caption2)
                    }

                    AsyncImage(url: URL(string: match.awayLogo)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 30, height: 30)
                }
            }
        }
        .navigationTitle("All Matches")
        .onAppear { loadMatches() }
        .onReceive(refreshTimer) { _ in loadMatches() }
    }

    var filteredMatches: [Match] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()

        return matches.filter { match in
            guard let matchDate = formatter.date(from: match.date) else { return false }

            switch selectedDay {
            case .yesterday:
                return Calendar.current.isDate(matchDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: today)!)
            case .today:
                return Calendar.current.isDate(matchDate, inSameDayAs: today)
            case .tomorrow:
                return Calendar.current.isDate(matchDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: today)!)
            }
        }
    }

    func loadMatches() {
        guard let url = URL(string: "http://127.0.0.1:5000/matches") else { return }
