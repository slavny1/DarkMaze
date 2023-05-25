//
//  WinView.swift
//  DarkMaze
//
//  Created by Viacheslav on 25/05/23.
//

import SwiftUI

struct WinView: View {

    @Binding var state: GameState

    var body: some View {
        VStack(alignment: .center) {
            Text("WIN")
                .foregroundColor(.white)
                .font(.system(size: 124, weight: .black, design: .monospaced))
            Button {
                //
            } label: {
                Text("Start again")
                    .frame(width: 250, height: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
            }
            Button {
                state = .main
            } label: {
                Text("Main menu")
                    .frame(width: 250, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .border(.white, width: 4)
            }
        }

    }
}

struct WinView_Previews: PreviewProvider {
    static var previews: some View {
        WinView(state: .constant(.game))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
