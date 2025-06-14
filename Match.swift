import Foundation

struct Match: Identifiable, Codable {
    let id: Int
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int
    let awayScore: Int
    let status: MatchStatus
    let sport: Sport
    let date: String
    let time: String
    let venue: String
    let competition: String
    let lastUpdated: String
    
    var formattedScore: String {
        return "\(homeScore) - \(awayScore)"
    }
    
    var isLive: Bool {
        return status == .live
    }
    
    var matchDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
    
    var formattedDate: String {
        guard let date = matchDate else { return date }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

enum MatchStatus: String, Codable {
    case upcoming = "Upcoming"
    case live = "Live"
    case fullTime = "Full Time"
    case halfTime = "Half Time"
    case cancelled = "Cancelled"
    case postponed = "Postponed"
    
    var color: String {
        switch self {
        case .live: return "green"
        case .upcoming: return "blue"
        case .fullTime: return "gray"
        case .halfTime: return "orange"
        case .cancelled, .postponed: return "red"
        }
    }
}

enum Sport: String, Codable {
    case football = "Football"
    case hurling = "Hurling"
    
    var icon: String {
        switch self {
        case .football: return "🏉"
        case .hurling: return "🏑"
        }
    }
    
    var color: String {
        switch self {
        case .football: return "green"
        case .hurling: return "blue"
        }
    }
}
