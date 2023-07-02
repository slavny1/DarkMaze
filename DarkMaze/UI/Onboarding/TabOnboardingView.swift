//
//  TabOnboardingView.swift
//  DarkMaze
//
//  Created by Viacheslav on 15/06/23.
//

import SwiftUI

struct TabOnboardingView: View {
    @State private var currentTab = 0

    private let list: [OnboardingData] = [
        OnboardingData(id: 0, primaryText: "Welcome to Dark Maze", secondaryText: "An immersive game for visually impaired individuals"),
        OnboardingData(id: 1, primaryText: "Explore complex Mazes", secondaryText: "Engage all your senses beyond vision"),
        OnboardingData(id: 2, primaryText: "Turn on sounds and haptic", secondaryText: "It's essential features for navigating through the Maze")
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentTab,
                    content:  {
                ForEach(list) { viewData in
                    OnboardingView(data: viewData)
                        .tag(viewData.id)
                }
            })
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            VStack {
                Spacer()
                LottieView(name: "hello", loop: .loop)
                    .frame(width: 350, height: 350)
                    .padding(.bottom, 300)
                HStack(spacing: 15) {
                    ForEach(list.indices, id: \.self) { index in
                        Capsule()
                            .fill(Color.white)
                            .frame(width: currentTab == index ? 20 : 7, height: 7)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct TabOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        TabOnboardingView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
