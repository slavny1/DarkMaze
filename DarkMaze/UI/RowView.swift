//
//  RowView.swift
//  DarkMaze
//
//  Created by Viacheslav on 13/06/23.
//

import SwiftUI

struct RowView: View {

    var level: Int

    var body: some View {

            HStack {
                Text("Level \(String(level))")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                Spacer()
                Image(systemName: "play")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
            }
            .padding()
            .border(.white, width: 4)
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(level: 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
