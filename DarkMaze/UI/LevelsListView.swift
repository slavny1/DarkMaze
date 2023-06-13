//
//  LevelsListView.swift
//  DarkMaze
//
//  Created by Viacheslav on 12/06/23.
//

import SwiftUI

struct LevelsListView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            ForEach(AppState.GameLevel.allCases, id: \.self) { level in
                HStack {
                    Button {
                        appState.gameLevel = AppState.GameLevel(rawValue: level.rawValue) ?? .zero
                        appState.state = .game
                    } label: {
                        Text("\(level.rawValue)")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

struct LevelsListView_Previews: PreviewProvider {
    static var previews: some View {
        LevelsListView()
        
    }
}
