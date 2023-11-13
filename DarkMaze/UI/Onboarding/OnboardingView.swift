//
//  OnboardingView.swift
//  DarkMaze
//
//  Created by Viacheslav on 15/06/23.
//

import SwiftUI

struct OnboardingView: View {

    @EnvironmentObject var appState: AppState
    var data: OnboardingData

    var body: some View {
        VStack {
            Spacer()
            Text(data.primaryText)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .black, design: .monospaced))
                .padding(.bottom, 10)
            Text(data.secondaryText)
                .padding(.bottom, 50)
                .padding(.horizontal)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)

            Button {
                appState.isOnboarding = false
            } label: {
                Text("Skip onboarding")
                    .frame(width: 200, height: 40)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .border(.white, width: 2)
            }
            .padding(.bottom, 100)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(data: OnboardingData(id: 0, primaryText: "Welcome to Dark Maze", secondaryText: "An immersive game for visually impaired individuals"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
