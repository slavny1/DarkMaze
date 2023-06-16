//
//  TabOnboardingView.swift
//  DarkMaze
//
//  Created by Viacheslav on 15/06/23.
//

import SwiftUI

struct TabOnboardingView: View {

    @State private var currentTab = 0

    var body: some View {
        ZStack {
            VStack {
            Spacer()
            LottieView(name: "hello", loop: .loop)
                .frame(width: 350, height: 350)
                .padding(.bottom, UIScreen.main.bounds.height / 2)

            }
            TabView(selection: $currentTab,
                    content:  {
                ForEach(OnboardingData.list) { viewData in
                    OnboardingView(data: viewData)
                        .tag(viewData.id)
                }
            })
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            VStack {
                Spacer()
                HStack(spacing: 15) {
                    ForEach(OnboardingData.list.indices, id: \.self) { index in
                        Capsule()
                            .fill(Color.white)
                            .frame(width: currentTab == index ? 20 : 7, height: 7)
                    }
                }
                .padding(.bottom)
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
