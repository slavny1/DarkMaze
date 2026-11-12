// Exercise the exact MazeLib.swift used by the iOS game, not a copied algorithm.
import Foundation

func verify(_ condition: @autoclosure () -> Bool, _ reason: String) {
    guard condition() else { fatalError("Maze validation failed: \(reason)") }
}

func connectedOpenCount(_ maze: [[UInt8]]) -> Int {
    let side = maze.count
    var queue = [(row: 0, column: 0)]
    var visited = Set<Int>([0])
    var cursor = 0
    while cursor < queue.count {
        let current = queue[cursor]
        cursor += 1
        for (rowOffset, columnOffset) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
            let row = current.row + rowOffset
            let column = current.column + columnOffset
            guard maze.indices.contains(row),
                  maze[row].indices.contains(column),
                  maze[row][column] == 1 else { continue }
            let index = row * side + column
            if visited.insert(index).inserted {
                queue.append((row, column))
            }
        }
    }
    return visited.count
}

let repeatsPerLevel = 25
var totalCases = 0

for stage in 0..<4 {
    let tutorial = MazeLibrary.tutorialMaze(stage: stage)
    verify(tutorial.tiles[0][0] == 1, "Tutorial \(stage): blocked start")
    verify(tutorial.tiles.indices.contains(tutorial.goal.row), "Tutorial \(stage): goal row")
    verify(tutorial.tiles[tutorial.goal.row].indices.contains(tutorial.goal.column),
           "Tutorial \(stage): goal column")
    verify(tutorial.tiles[tutorial.goal.row][tutorial.goal.column] == 1,
           "Tutorial \(stage): blocked goal")
    totalCases += 1
}

for level in AppState.GameLevel.allCases {
    let side = level.rawValue + 5
    var previous: [[UInt8]]?
    var uniqueLayouts = Set<String>()
    for trial in 1...repeatsPerLevel {
        let maze = MazeLibrary.randomMaze(level: level)
        verify(maze.count == side && maze.allSatisfy { $0.count == side },
               "Level \(side), case \(trial): shape")
        verify(maze.allSatisfy { row in row.allSatisfy { $0 == 0 || $0 == 1 } },
               "Level \(side), case \(trial): unexpected cell value")
        verify(MazeLibrary.isPlayable(maze), "Level \(side), case \(trial): validation")
        let shortest = MazeLibrary.shortestPathLength(maze)
        verify(shortest != nil && shortest! > 2 * side,
               "Level \(side), case \(trial): shortest path \(String(describing: shortest))")
        let passageCount = maze.flatMap { $0 }.filter { $0 == 1 }.count
        verify(connectedOpenCount(maze) == passageCount,
               "Level \(side), case \(trial): disconnected passage")
        verify(MazeLibrary.obeysRunLimit(maze),
               "Level \(side), case \(trial): four identical cells in a row")
        verify(MazeLibrary.hasSingleCellCorridors(maze),
               "Level \(side), case \(trial): open room of 2x2 cells")
        if let previous {
            verify(previous != maze, "Level \(side), case \(trial): immediate layout repeat")
        }
        previous = maze
        uniqueLayouts.insert(maze.map { $0.map(String.init).joined() }.joined(separator: "/"))
        totalCases += 1
    }
    verify(uniqueLayouts.count >= 2, "Level \(side): only one repeated layout")
    print("✅ \(side)x\(side): \(repeatsPerLevel) layouts; \(uniqueLayouts.count) unique")
}

let allClosed = Array(repeating: Array(repeating: UInt8(0), count: 5), count: 5)
let allOpen = Array(repeating: Array(repeating: UInt8(1), count: 5), count: 5)
verify(!MazeLibrary.isPlayable(allClosed), "Fully blocked map accepted")
verify(!MazeLibrary.isPlayable(allOpen), "Open plaza map accepted")
verify(!MazeLibrary.isPlayable([[1, 0], [0, 1]]), "Tiny invalid map accepted")
print("✅ \(totalCases) maze/tutorial cases + invalid-map checks passed")
