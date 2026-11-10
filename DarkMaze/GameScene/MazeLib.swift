//
//  MazeLib.swift
//  DarkMaze
//

import Foundation

enum MazeLibrary {
    private static var lastGenerated: [AppState.GameLevel: [[UInt8]]] = [:]
    private static let directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]

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
        let side = level.rawValue + 4
        let previous = lastGenerated[level]
        var best: [[UInt8]]?
        var highestScore = Int.min

        // Compare valid, one-cell-wide layouts to favour intersections.
        // The finite attempt limit protects app launch performance.
        for _ in 0..<12 {
            guard let candidate = candidateMaze(side: side),
                  candidate != previous,
                  hasPathToExit(candidate),
                  obeysRunLimit(candidate),
                  hasSingleCellCorridors(candidate) else { continue }
            let score = interestScore(candidate)
            if score > highestScore {
                best = candidate
                highestScore = score
            }
        }
        // An alternate valid layout with a guaranteed route is always available.
        let maze = best ?? fallbackMaze(side: side)
        precondition(hasPathToExit(maze) &&
                     obeysRunLimit(maze) &&
                     hasSingleCellCorridors(maze))
        lastGenerated[level] = maze
        return maze
    }

    // On 4x4, N-3 = 1 would forbid two adjacent passage cells and thus
    // any route between corners. The smallest feasible run is two.
    private static func runLimit(side: Int) -> Int {
        3
    }

    private static func candidateMaze(side: Int) -> [[UInt8]]? {
        // Plant a randomized route from start to finish before adding
        // side passages. A monotone route always terminates at the goal.
        let limit = runLimit(side: side)
        var compulsory = Set<Int>([0])
        var row = 0
        var column = 0
        var lastDirection = -1
        var directionStreak = 0
        while row < side - 1 || column < side - 1 {
            let options = [0, 1].filter { direction in
                let available = direction == 0 ? column < side - 1 : row < side - 1
                return available && (direction != lastDirection || directionStreak < limit - 1)
            }
            guard let selected = options.randomElement() else { return nil }
            if selected == 0 { column += 1 } else { row += 1 }
            compulsory.insert(row * side + column)
            directionStreak = selected == lastDirection ? directionStreak + 1 : 1
            lastDirection = selected
        }

        var cells = Array(repeating: Array(repeating: UInt8(2), count: side), count: side)
        var searchCount = 0

        func canPlace(_ value: UInt8, row: Int, column: Int) -> Bool {
            var horizontalRun = 1
            var previousColumn = column - 1
            while previousColumn >= 0 && cells[row][previousColumn] == value {
                horizontalRun += 1
                previousColumn -= 1
            }
            guard horizontalRun <= limit else { return false }

            var verticalRun = 1
            var previousRow = row - 1
            while previousRow >= 0 && cells[previousRow][column] == value {
                verticalRun += 1
                previousRow -= 1
            }
            guard verticalRun <= limit else { return false }
            // Never carve an open 2x2 area; corridors stay one tile wide.
            if value == 1 && row > 0 && column > 0 &&
                cells[row - 1][column] == 1 &&
                cells[row][column - 1] == 1 &&
                cells[row - 1][column - 1] == 1 {
                return false
            }
            return true
        }

        func fill(_ index: Int) -> Bool {
            searchCount += 1
            guard searchCount < 20_000 else { return false }
            if index == side * side { return true }
            let currentRow = index / side
            let currentColumn = index % side
            let choices: [UInt8] = compulsory.contains(index) ? [1] :
                (Bool.random() ? [1, 0] : [0, 1])
            for choice in choices where canPlace(choice, row: currentRow, column: currentColumn) {
                cells[currentRow][currentColumn] = choice
                if fill(index + 1) { return true }
                cells[currentRow][currentColumn] = 2
            }
            return false
        }

        return fill(0) ? cells : nil
    }

    private static func fallbackMaze(side: Int) -> [[UInt8]] {
        // Guaranteed diagonal stair path; complete the remaining cells
        // using backtracking under the same run-length constraints.
        let limit = runLimit(side: side)
        var maze = Array(repeating: Array(repeating: UInt8(2), count: side), count: side)
        var required = Set<Int>()
        for index in 0..<side {
            required.insert(index * side + index)
            if index < side - 1 { required.insert(index * side + index + 1) }
        }

        func fits(_ value: UInt8, row: Int, column: Int) -> Bool {
            var horizontal = 1
            var checkColumn = column - 1
            while checkColumn >= 0 && maze[row][checkColumn] == value {
                horizontal += 1
                checkColumn -= 1
            }
            guard horizontal <= limit else { return false }
            var vertical = 1
            var checkRow = row - 1
            while checkRow >= 0 && maze[checkRow][column] == value {
                vertical += 1
                checkRow -= 1
            }
            guard vertical <= limit else { return false }
            if value == 1 && row > 0 && column > 0 &&
                maze[row - 1][column] == 1 &&
                maze[row][column - 1] == 1 &&
                maze[row - 1][column - 1] == 1 {
                return false
            }
            return true
        }

        func fill(_ index: Int) -> Bool {
            if index == side * side { return true }
            let row = index / side
            let column = index % side
            let options: [UInt8] = required.contains(index) ? [1] : [0, 1]
            for option in options where fits(option, row: row, column: column) {
                maze[row][column] = option
                if fill(index + 1) { return true }
                maze[row][column] = 2
            }
            return false
        }

        precondition(fill(0), "Unable to construct a bounded fallback maze")
        return maze
    }

    static func obeysRunLimit(_ maze: [[UInt8]]) -> Bool {
        let side = maze.count
        guard side > 0, maze.allSatisfy({ $0.count == side }) else { return false }
        let limit = runLimit(side: side)
        for row in 0..<side {
            for horizontal in [true, false] {
                var previous: UInt8 = 2
                var runLength = 0
                for column in 0..<side {
                    let value = horizontal ? maze[row][column] : maze[column][row]
                    runLength = value == previous ? runLength + 1 : 1
                    if runLength > limit { return false }
                    previous = value
                }
            }
        }
        return true
    }

    // A 2x2 open square creates a room instead of a narrow passage.
    static func hasSingleCellCorridors(_ maze: [[UInt8]]) -> Bool {
        let side = maze.count
        guard side > 0, maze.allSatisfy({ $0.count == side }) else { return false }
        guard side >= 2 else { return true }
        for row in 1..<side {
            for column in 1..<side {
                if maze[row][column] == 1 &&
                    maze[row - 1][column] == 1 &&
                    maze[row][column - 1] == 1 &&
                    maze[row - 1][column - 1] == 1 {
                    return false
                }
            }
        }
        return true
    }

    private static func interestScore(_ maze: [[UInt8]]) -> Int {
        let side = maze.count
        var intersections = 0
        var walkable = 0
        for row in 0..<side {
            for column in 0..<side where maze[row][column] == 1 {
                walkable += 1
                let neighbors = directions.filter { offset in
                    let nextRow = row + offset.0
                    let nextColumn = column + offset.1
                    return nextRow >= 0 && nextColumn >= 0 &&
                        nextRow < side && nextColumn < side &&
                        maze[nextRow][nextColumn] == 1
                }.count
                if neighbors >= 3 { intersections += 1 }
            }
        }
        // Prefer distinct intersections but avoid filling the entire grid.
        return intersections * 7 - abs(walkable - side * side * 2 / 3)
    }

    static func hasPathToExit(_ maze: [[UInt8]]) -> Bool {
        let side = maze.count
        guard side > 0, maze.allSatisfy({ $0.count == side }),
              maze[0][0] == 1, maze[side - 1][side - 1] == 1 else { return false }

        var visited = Array(repeating: Array(repeating: false, count: side), count: side)
        var queue = [(0, 0)]
        visited[0][0] = true
        var index = 0
        while index < queue.count {
            let current = queue[index]
            index += 1
            if current.0 == side - 1 && current.1 == side - 1 { return true }
            for direction in directions {
                let nextRow = current.0 + direction.0
                let nextColumn = current.1 + direction.1
                guard nextRow >= 0 && nextColumn >= 0 &&
                        nextRow < side && nextColumn < side &&
                        !visited[nextRow][nextColumn] &&
                        maze[nextRow][nextColumn] == 1 else { continue }
                visited[nextRow][nextColumn] = true
                queue.append((nextRow, nextColumn))
            }
        }
        return false
    }
}
