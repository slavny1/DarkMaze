//
//  MainView.swift
//  DarkMaze
//
//  Created by Viacheslav on 25/05/23.
//

import SwiftUI
import AudioToolbox
import CoreHaptics

struct MainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: -50) {
                Text("DARK")
                Text("MAZE")
            }
            .foregroundColor(.white)
            .font(.system(size: 124, weight: .black, design: .monospaced))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Dark Maze")
            .accessibilityHint("Main menu of the game")
            Text("Top level: \(appState.topLevel.rawValue)")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .black, design: .monospaced))
            Button {
                appState.state = .game
                appState.gameLevel = appState.topLevel
                HapticManager.buttonTapped()
            } label: {
                Text("Start game")
                    .frame(width: 250, height: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
            }
            .accessibilityHint("Will start a new game at level \(appState.topLevel.rawValue)")
            Button {
                appState.state = .level
                HapticManager.buttonTapped()
            } label: {
                Text("Levels")
                    .frame(width: 250, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .border(.white, width: 4)
            }
            .accessibilityHint("Open a list of levels")
            Toggle(isOn: $appState.blindMode) {
                Text(appState.blindMode ? "Blind mode on" : "Blind mode off")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .padding(.leading)
            }
            .toggleStyle(BlindModeToggleStyle())
            .frame(width: 250, height: 40)
            .onChange(of: appState.blindMode) { newValue in
                // Play system sound effect for toggle switching
                AudioServicesPlaySystemSound(1104) // Use the desired system sound effect ID
                HapticManager.buttonTapped()
            }
            .accessibilityHidden(true)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            .environmentObject(AppState())
    }
}
