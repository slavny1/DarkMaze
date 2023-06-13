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
        ScrollView {
            ForEach(AppState.GameLevel.allCases, id: \.self) { level in
                HStack {
                    Button {
                        if appState.topLevel >= level.rawValue {
                            appState.gameLevel = AppState.GameLevel(rawValue: level.rawValue) ?? .zero
                            appState.state = .game
                        }
                    } label: {
                        RowView(level: level.rawValue, available: appState.topLevel >= level.rawValue)
                    }
                }
            }
        }
        .padding(.top, 24)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("LEVEL")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    appState.state = .main
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                        Text("Main")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LevelsListView_Previews: PreviewProvider {
    static var previews: some View {
        LevelsListView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}