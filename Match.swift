import Foundation

struct Match: Identifiable, Decodable {
    let id: Int
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int
    let awayScore: Int
    let status: String
    let sport: String
    let date: String
    let time: String
    let venue: String
    let homeLogo: String
    let awayLogo: String
}
