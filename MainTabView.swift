//
//  MainTabView.swift
//  GAWA
//
//  Created by Paul Cahill on 04/05/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("My Team", systemImage: "star.fill")
                }

            AllMatchesView()
                .tabItem {
                    Label("All Matches", systemImage: "list.bullet.rectangle")
                }

            StandingsView()
                .tabItem {
                    Label("Standings", systemImage: "tablecells")
                }

            TeamSelectorView()
                .tabItem {
                    Label("Follow", systemImage: "person.crop.circle")
                }
        }
    }
}
