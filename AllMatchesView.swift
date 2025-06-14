import SwiftUI

struct AllMatchesView: View {
    @StateObject private var viewModel = MatchViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom tab bar
                HStack(spacing: 0) {
                    TabButton(title: "All", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "Live", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    TabButton(title: "Today", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Content
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading matches...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text("Error loading matches")
                                .font(.headline)
                            Text(error.localizedDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Try Again") {
                                Task {
                                    await viewModel.refreshMatches()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredMatches.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "sportscourt")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("No matches available")
                                .font(.headline)
                            Text("Check back later for upcoming matches")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredMatches) { match in
                                    MatchRow(match: match)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .refreshable {
                            await viewModel.refreshMatches()
                        }
                    }
                }
            }
            .navigationTitle("GAA Matches")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refreshMatches()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            await viewModel.fetchMatches()
        }
    }
    
    var filteredMatches: [Match] {
        switch selectedTab {
        case 0:
            return viewModel.matches
        case 1:
            return viewModel.matches.filter { $0.isLive }
        case 2:
            let today = Date()
            return viewModel.matches.filter { match in
                guard let matchDate = match.matchDate else { return false }
                return Calendar.current.isDate(matchDate, inSameDayAs: today)
            }
        default:
            return viewModel.matches
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    VStack {
                        Spacer()
                        if isSelected {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(height: 2)
                        }
                    }
                )
        }
    }
}

struct MatchRow: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 0) {
            // Competition header
            HStack {
                Text(match.competition)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(match.sport.icon)
                    .font(.caption)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            // Match content
            VStack(spacing: 12) {
                // Teams and score
                HStack(alignment: .center, spacing: 16) {
                    // Home team
                    VStack(alignment: .trailing) {
                        Text(match.homeTeam)
                            .font(.headline)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    // Score or time
                    if match.status == .upcoming {
                        Text(match.time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text(match.formattedScore)
                            .font(.title2)
                            .bold()
                            .foregroundColor(match.isLive ? .green : .primary)
                    }
                    
                    // Away team
                    VStack(alignment: .leading) {
                        Text(match.awayTeam)
                            .font(.headline)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                // Match info footer
                HStack {
                    // Status indicator
                    if match.isLive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    // Venue
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        Text(match.venue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color(.secondarySystemBackground))
        }
        .cornerRadius(12)
    }
}

#Preview {
    AllMatchesView()
}
