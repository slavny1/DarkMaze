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

            LottieView(name: data.lottie, loop: .loop)
                .frame(width: 350, height: 350)
                .padding(.vertical)

            Text(data.primaryText)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .black, design: .monospaced))
                .padding(.bottom, 10)
            Text(data.secondaryText)
                .padding(.bottom, 50)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)

            Button {
                appState.isOnboarding = true
            } label: {
                Text("Skip onboarding")
                    .frame(width: 200, height: 40)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .border(.white, width: 2)
            }
            .padding(.bottom)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(data: OnboardingData.list.first!)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
