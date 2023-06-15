//
//  OnboardingView.swift
//  DarkMaze
//
//  Created by Viacheslav on 15/06/23.
//

import SwiftUI

struct OnboardingView: View {

    var data: OnboardingData

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(data: OnboardingData.list.first!)
    }
}
