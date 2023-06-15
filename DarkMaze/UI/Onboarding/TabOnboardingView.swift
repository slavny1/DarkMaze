//
//  TabOnboardingView.swift
//  DarkMaze
//
//  Created by Viacheslav on 15/06/23.
//

import SwiftUI

struct TabOnboardingView: View {

    @State private var currentTab = 1

    var body: some View {
        TabView(selection: $currentTab,
                content:  {
            ForEach(OnboardingData.list) { viewData in
                OnboardingView(data: viewData)
                    .tag(viewData.id)
            }
        })
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
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
