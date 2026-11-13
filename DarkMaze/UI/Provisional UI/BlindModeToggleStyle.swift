//
//  BlindModeToggleStyle.swift
//  DarkMaze
//

import SwiftUI

struct BlindModeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
            HapticManager.buttonTapped()
        } label: {
            HStack {
                configuration.label
                Spacer()
                RoundedRectangle(cornerRadius: 20)
                    .fill(configuration.isOn ? Color.green : Color.gray)
                    .frame(width: 50, height: 30)
                    .overlay {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .offset(x: configuration.isOn ? 10 : -10)
                    }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityValue(configuration.isOn ? "On" : "Off")
        .accessibilityHint("Double tap to change this setting")
    }
}
