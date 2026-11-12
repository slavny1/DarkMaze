// This stand-in keeps the maze rules compiling directly from their production source.
// The automated Swift CLI harness intentionally excludes UIKit, SwiftUI and SpriteKit.
enum AppState {
    enum GameLevel: Int, CaseIterable {
        case zero, one, two, three, four, five, six
    }
}
