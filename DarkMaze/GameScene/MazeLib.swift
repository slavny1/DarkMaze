//
//  MazeLib.swift
//  DarkMaze
//

import Foundation

enum MazeLibrary {
    // Only the three guided tutorials use fixed layouts.
    // Regular levels get a new randomized maze on every run or replay.
    private static var lastGenerated: [AppState.GameLevel: [[UInt8]]] = [:]

    private static let directions: [(row: Int, column: Int)] = [
        (1, 0), (-1, 0), (0, 1), (0, -1)
    ]

    // Bottom-left is the starting tile. Tutorial goal is defined separately
    // so the first exercise can be an actual straight corridor.
    static func tutorialMaze(stage: Int) -> (tiles: [[UInt8]], goal: (row: Int, column: Int)) {
        switch stage {
        case 0:
            return ([
                [1, 0, 0, 0],
                [1, 0, 0, 0],
                [1, 0, 0, 0],
                [1, 0, 0, 0]
            ], (3, 0))
        case 1:
            return ([
                [1, 0, 0, 0],
                [1, 0, 0, 0],
                [1, 0, 0, 0],
                [1, 1, 1, 1]
            ], (3, 3))
        default:
            return ([
                [1, 0, 0, 0, 0],
                [1, 1, 1, 0, 0],
                [0, 0, 1, 0, 0],
                [0, 0, 1, 1, 1],
                [0, 0, 0, 0, 1]
            ], (4, 4))
        }
    }

    static func randomMaze(level: AppState.GameLevel) -> [[UInt8]] {
        // Visible levels 1...7: grids from 4x4 through 10x10.
        let side = level.rawValue + 4
        var maze = generateMaze(side: side)

        if let previous = lastGenerated[level] {
            // Avoid immediately repeating an identical maze on "Play again".
            var attempts = 0
            while maze == previous && attempts < 30 {
                maze = generateMaze(side: side)
                attempts += 1
            }

            // Guaranteed difference even if randomness repeatedly returned
            // the same layout. Opening a wall cannot remove the valid route.
            if maze == previous {
                changeOneWall: for row in 0..<side {
                    for column in 0..<side where maze[row][column] == 0 {
                        maze[row][column] = 1
                        break changeOneWall
                    }
                }
            }
        }

        precondition(hasPathToExit(maze), "Maze must contain a path to the exit")
        lastGenerated[level] = maze
        return maze
    }

    // Iterative randomized depth-first carving on a coarse grid.
    // Every carved node is connected, so the start can reach the exit.
    private static func generateMaze(side: Int) -> [[UInt8]] {
        var maze = Array(repeating: Array(repeating: UInt8(0), count: side), count: side)
        let coarseSide = (side + 1) / 2
        var visited = Array(repeating: Array(repeating: false, count: coarseSide), count: coarseSide)
        var stack: [(row: Int, column: Int)] = [(0, 0)]

        maze[0][0] = 1
        visited[0][0] = true

        while let current = stack.last {
            let neighbors = directions.shuffled().compactMap { direction -> (row: Int, column: Int)? in
                let nextRow = current.row + direction.row
                let nextColumn = current.column + direction.column
                guard nextRow >= 0, nextRow < coarseSide,
                      nextColumn >= 0, nextColumn < coarseSide,
                      !visited[nextRow][nextColumn] else { return nil }
                return (row: nextRow, column: nextColumn)
            }

            if let next = neighbors.first {
                // Carve a connecting passage between neighbouring nodes.
                let passageRow = current.row * 2 + next.row - current.row
                let passageColumn = current.column * 2 + next.column - current.column
                maze[passageRow][passageColumn] = 1
                maze[next.row * 2][next.column * 2] = 1
                visited[next.row][next.column] = true
                stack.append(next)
            } else {
                stack.removeLast()
            }
        }

        // On even grids the bottom-right corner is not a coarse-grid node.
        // Attach it to the connected node at (side-2, side-2).
        if side.isMultiple(of: 2) {
            maze[side - 1][side - 1] = 1
            if Bool.random() {
                maze[side - 2][side - 1] = 1
            } else {
                maze[side - 1][side - 2] = 1
            }
        }
        return maze
    }

    // Independent reachability check used for every generated maze.
    static func hasPathToExit(_ maze: [[UInt8]]) -> Bool {
        let side = maze.count
        guard side > 0,
              maze.allSatisfy({ $0.count == side }),
              maze[0][0] == 1,
              maze[side - 1][side - 1] == 1 else { return false }

        var visited = Array(repeating: Array(repeating: false, count: side), count: side)
        var queue: [(row: Int, column: Int)] = [(0, 0)]
        visited[0][0] = true
        var index = 0

        while index < queue.count {
            let current = queue[index]
            index += 1
            if current.row == side - 1 && current.column == side - 1 {
                return true
            }

            for direction in directions {
                let nextRow = current.row + direction.row
                let nextColumn = current.column + direction.column
                guard nextRow >= 0, nextRow < side,
                      nextColumn >= 0, nextColumn < side,
                      !visited[nextRow][nextColumn],
                      maze[nextRow][nextColumn] == 1 else { continue }
                visited[nextRow][nextColumn] = true
                queue.append((row: nextRow, column: nextColumn))
            }
        }
        return false
    }
}
