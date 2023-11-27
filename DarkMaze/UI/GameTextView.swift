//
//  GameTextView.swift
//  DarkMaze
//
//  Created by Viacheslav on 27/11/23.
//

import SwiftUI

struct GameTextView: View {
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            .font(.system(size: 18, weight: .black, design: .monospaced))
            .padding()
            .border(.white, width: 4)
    }
}

#Preview {
    GameTextView()
        .background(Color.black)
}
