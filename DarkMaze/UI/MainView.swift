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
    @Binding var blindMode: Bool

    private let toggleTappedHaptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: -50) {
                Text("DARK")
                Text("MAZE")
            }
            .foregroundColor(.white)
            .font(.system(size: 124, weight: .black, design: .monospaced))
            Button {
                appState.state = .game
            } label: {
                Text("Start game")
                    .frame(width: 250, height: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
            }
            Button {
                appState.state = .level
            } label: {
                Text("Levels")
                    .frame(width: 250, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .border(.white, width: 4)
            }
            Toggle(isOn: $blindMode) {
                Text(blindMode ? "Blind mode on" : "Blind mode off")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .padding(.leading)
            }
            .toggleStyle(BlindModeToggleStyle())
            .frame(width: 250, height: 40)
            .onChange(of: blindMode) { newValue in
                // Play system sound effect for toggle switching
                AudioServicesPlaySystemSound(1104) // Use the desired system sound effect ID
                toggleTappedHaptic.impactOccurred()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(blindMode: .constant(false))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
