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
                        if appState.topLevel >= level {
                            appState.gameLevel = level
                            appState.state = .game
                        }
                        HapticManager.buttonTapped()
                    } label: {
                        RowView(level: level, isAvailable: appState.topLevel >= level)
                    }
                    .disabled(appState.topLevel < level)
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
    @ObservedObject static var appState = AppState()
    
    static var previews: some View {
        LevelsListView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            .environmentObject(AppState())
    }
}
