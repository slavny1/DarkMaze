//
//  RowView.swift
//  DarkMaze
//
//  Created by Viacheslav on 13/06/23.
//

import SwiftUI

struct RowView: View {

    var level: AppState.GameLevel
    var isAvailable: Bool

    var body: some View {

            HStack {
                Text("Level \(String(level.rawValue))")
                    .foregroundColor(isAvailable ? .white : .gray)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                Spacer()
                Image(systemName: isAvailable ? "play" : "play.slash")
                    .foregroundColor(isAvailable ? .white : .gray)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
            }
            .padding()
            .border(isAvailable ? .white : .gray, width: 4)
            .accessibilityLabel(isAvailable ? "Level \(String(level.rawValue))" : "Level \(String(level.rawValue)) unavailable")
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(level: .one, isAvailable: false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
