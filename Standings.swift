//
//  Standings.swift
//  GAWA
//
//  Created by Paul Cahill on 04/05/2025.
//

import SwiftUI

struct TeamStanding: Identifiable, Decodable {
    let id: String
    let team: String
    let played: Int
    let won: Int
    let drawn: Int
    let lost: Int
    let points: Int
}

struct StandingsView: View {
    @State private var table: [TeamStanding] = []

    var body: some View {
        List(table) { row in
            HStack {
                Text(row.team)
                Spacer()
                Text("\(row.played)P \(row.won)W \(row.drawn)D \(row.lost)L \(row.points)pts")
                    .font(.caption)
            }
        }
        .navigationTitle("Standings")
        .onAppear { loadStandings() }
    }

    func loadStandings() {
        guard let url = URL(string: "http://127.0.0.1:5000/standings") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([TeamStanding].self, from: data) {
                DispatchQueue.main.async {
                    table = decoded
                }
            }
        }.resume()
    }
}
