import Foundation
import Combine

@MainActor
class MatchViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "http://localhost:5001/api"
    
    func fetchMatches() async {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "\(baseURL)/matches") else {
            error = URLError(.badURL)
            isLoading = false
            return
        }
        
        do {
            let (data, httpResponse) = try await URLSession.shared.data(from: url)
            
            // Debug logging
            if let httpResponse = httpResponse as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
            }
            
            // Debug logging for received data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received data: \(jsonString)")
            }
            
            // Decode the matches array directly
            matches = try JSONDecoder().decode([Match].self, from: data)
            
            // Sort matches by date and time
            matches.sort { match1, match2 in
                guard let date1 = match1.matchDate,
                      let date2 = match2.matchDate else {
                    return false
                }
                return date1 < date2
            }
            
            print("Successfully loaded \(matches.count) matches")
        } catch {
            self.error = error
            print("Error fetching matches: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func refreshMatches() async {
        await fetchMatches()
    }
}

struct MatchResponse: Codable {
    let data: [Match]
} 