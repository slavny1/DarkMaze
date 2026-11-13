//
//  MazeLib.swift
//  DarkMaze
//

import Foundation

enum MazeLibrary {
    private static var lastGenerated: [AppState.GameLevel: [[UInt8]]] = [:]
    private static let offsets = [(1, 0), (-1, 0), (0, 1), (0, -1)]

    // Teaching layouts stay deterministic. Only normal levels are randomized.
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
        // 4x4 cannot meet the strict >2N path rule together with narrow,
        // connected passages and 3-cell run limits. Normal levels use 5...11.
        let side = level.rawValue + 5
        let previous = lastGenerated[level]
        var candidates: [[[UInt8]]] = []

        for _ in 0..<16 {
            guard let proposed = makeRandomMaze(side: side),
                  isPlayable(proposed),
                  proposed != previous else { continue }
            candidates.append(proposed)
            if candidates.count == 3 { break }
        }

        // Prevalidated templates are the bounded-time safety net. Apply
        // a corner-preserving symmetry so retries need not repeat the map.
        let maze: [[UInt8]]
        if let selected = candidates.randomElement() {
            maze = selected
        } else {
            let variants = (0..<4).map { transformedFallback(side: side, variant: $0) }
            maze = variants.filter { $0 != previous }.randomElement() ?? variants[0]
        }

        precondition(isPlayable(maze), "Generated maze violates playability rules")
        lastGenerated[level] = maze
        return maze
    }

    // A randomized long, self-avoiding route followed by connected
    // dead-end branches. Each new passage has exactly one open neighbor,
    // so it can never create a shortcut to the finish or a disconnected room.
    private static func makeRandomMaze(side: Int) -> [[UInt8]]? {
        let goal = side * side - 1
        var passages = Set<Int>([0])
        var path: [Int] = [0]
        var explored = 0

        func growRoute(from current: Int) -> Bool {
            explored += 1
            if explored > 12_000 { return false }
            if current == goal { return path.count - 1 > 2 * side }
            if path.count > 4 * side + 3 { return false }

            for next in neighbors(of: current, side: side).shuffled() {
                if passages.contains(next) { continue }
                if next == goal && path.count <= 2 * side { continue }
                if neighbors(of: next, side: side).filter({ passages.contains($0) }).count != 1 {
                    continue
                }
                if wouldCreateFourPassages(at: next, side: side, passages: passages) {
                    continue
                }

                passages.insert(next)
                path.append(next)
                if growRoute(from: next) { return true }
                path.removeLast()
                passages.remove(next)
            }
            return false
        }

        guard growRoute(from: 0) else { return nil }

        // Repair four-cell-long wall runs by carving only dead-end cells
        // connected to the existing route. This preserves unique long paths.
        for _ in 0..<(side * side) {
            let runs = closedRuns(of: passages, side: side)
            if runs.isEmpty { break }
            let candidates = Set(runs.flatMap { $0 })
                .filter { !passages.contains($0) }
                .filter { neighbors(of: $0, side: side).filter(passages.contains).count == 1 }
                .filter { !wouldCreateFourPassages(at: $0, side: side, passages: passages) }

            var best: [Int] = []
            var bestBenefit = 0
            for candidate in candidates {
                let count = runs.filter { $0.contains(candidate) }.count
                if count > bestBenefit {
                    bestBenefit = count
                    best = [candidate]
                } else if count == bestBenefit {
                    best.append(candidate)
                }
            }
            guard let next = best.randomElement() else { return nil }
            passages.insert(next)
        }

        guard closedRuns(of: passages, side: side).isEmpty else { return nil }

        // Add a few optional branches without loops, plazas or shortcuts.
        for _ in 0..<side {
            let branches = (0..<(side * side))
                .filter { !passages.contains($0) }
                .filter { neighbors(of: $0, side: side).filter(passages.contains).count == 1 }
                .filter { !wouldCreateFourPassages(at: $0, side: side, passages: passages) }
            if let next = branches.randomElement() { passages.insert(next) }
        }

        return (0..<side).map { row in
            (0..<side).map { column in
                passages.contains(row * side + column) ? UInt8(1) : UInt8(0)
            }
        }
    }

    private static func neighbors(of cell: Int, side: Int) -> [Int] {
        let row = cell / side
        let column = cell % side
        return offsets.compactMap { offset in
            let nextRow = row + offset.0
            let nextColumn = column + offset.1
            guard (0..<side).contains(nextRow),
                  (0..<side).contains(nextColumn) else { return nil }
            return nextRow * side + nextColumn
        }
    }

    private static func wouldCreateFourPassages(
        at cell: Int, side: Int, passages: Set<Int>
    ) -> Bool {
        let row = cell / side
        let column = cell % side
        for axis in 0..<2 {
            for start in -3...0 {
                let isRun = (0..<4).allSatisfy { step in
                    let currentRow = row + (axis == 0 ? start + step : 0)
                    let currentColumn = column + (axis == 1 ? start + step : 0)
                    guard (0..<side).contains(currentRow),
                          (0..<side).contains(currentColumn) else { return false }
                    let currentCell = currentRow * side + currentColumn
                    return currentCell == cell || passages.contains(currentCell)
                }
                if isRun { return true }
            }
        }
        return false
    }

    private static func closedRuns(of passages: Set<Int>, side: Int) -> [[Int]] {
        var result: [[Int]] = []
        for row in 0..<side {
            for column in 0..<(side - 3) {
                let across = (0..<4).map { row * side + column + $0 }
                if across.allSatisfy({ !passages.contains($0) }) { result.append(across) }
                let down = (0..<4).map { (column + $0) * side + row }
                if down.allSatisfy({ !passages.contains($0) }) { result.append(down) }
            }
        }
        return result
    }

    static func shortestPathLength(_ maze: [[UInt8]]) -> Int? {
        let side = maze.count
        guard side > 0, maze.allSatisfy({ $0.count == side }),
              maze[0][0] == 1, maze[side - 1][side - 1] == 1 else { return nil }
        let distances = distancesFromStart(maze)
        let goalDistance = distances[side - 1][side - 1]
        return goalDistance >= 0 ? goalDistance : nil
    }

    private static func distancesFromStart(_ maze: [[UInt8]]) -> [[Int]] {
        let side = maze.count
        var distances = Array(repeating: Array(repeating: -1, count: side), count: side)
        var queue = [(0, 0)]
        distances[0][0] = 0
        var index = 0
        while index < queue.count {
            let position = queue[index]
            index += 1
            for offset in offsets {
                let row = position.0 + offset.0
                let column = position.1 + offset.1
                guard (0..<side).contains(row), (0..<side).contains(column),
                      maze[row][column] == 1,
                      distances[row][column] == -1 else { continue }
                distances[row][column] = distances[position.0][position.1] + 1
                queue.append((row, column))
            }
        }
        return distances
    }

    static func isPlayable(_ maze: [[UInt8]]) -> Bool {
        let side = maze.count
        guard side >= 5, maze.allSatisfy({ $0.count == side }),
              let distance = shortestPathLength(maze), distance > 2 * side,
              obeysRunLimit(maze), hasSingleCellCorridors(maze) else { return false }
        let visited = distancesFromStart(maze)
        for row in 0..<side {
            for column in 0..<side where maze[row][column] == 1 {
                if visited[row][column] < 0 { return false }
            }
        }
        return true
    }

    static func hasPathToExit(_ maze: [[UInt8]]) -> Bool {
        shortestPathLength(maze) != nil
    }

    static func obeysRunLimit(_ maze: [[UInt8]]) -> Bool {
        let side = maze.count
        guard side > 0, maze.allSatisfy({ $0.count == side }) else { return false }
        for row in 0..<side {
            for horizontal in [true, false] {
                var run = 0
                var previous: UInt8 = 2
                for column in 0..<side {
                    let value = horizontal ? maze[row][column] : maze[column][row]
                    run = value == previous ? run + 1 : 1
                    if run > 3 { return false }
                    previous = value
                }
            }
        }
        return true
    }

    static func hasSingleCellCorridors(_ maze: [[UInt8]]) -> Bool {
        let side = maze.count
        guard side > 0, maze.allSatisfy({ $0.count == side }) else { return false }
        for row in 1..<side {
            for column in 1..<side {
                if maze[row][column] == 1 &&
                    maze[row - 1][column] == 1 &&
                    maze[row][column - 1] == 1 &&
                    maze[row - 1][column - 1] == 1 { return false }
            }
        }
        return true
    }

    private static func transformedFallback(side: Int, variant: Int) -> [[UInt8]] {
        let rows = fallbackRows[side]!
        let original = rows.map { row in
            Array(row).map { $0 == "1" ? UInt8(1) : UInt8(0) }
        }
        let last = side - 1
        return (0..<side).map { row in
            (0..<side).map { column in
                switch variant {
                case 1: return original[last - row][last - column]
                case 2: return original[column][row]
                case 3: return original[last - column][last - row]
                default: return original[row][column]
                }
            }
        }
    }

    // Verified layouts for bounded-time fallback, not the primary generator.
    private static let fallbackRows: [Int: [String]] = [
        5: [
            "10111", "11101", "01011", "11010", "10111"
        ],
        6: [
            "111001", "001011", "111010", "100111", "110101", "011101"
        ],
        7: [
            "1010100", "1110111", "1011101", "0101011",
            "1110110", "0011101", "1110111"
        ],
        8: [
            "10111000", "11101000", "01000100", "11100111",
            "10011101", "11101011", "01011010", "01110111"
        ],
        9: [
            "111001110", "100111010", "111010011",
            "001110101", "011000111", "110011100",
            "010110011", "001101110", "000111011"
        ],
        10: [
            "1011011100", "1010001000", "1110011101",
            "0101110111", "1101011001", "1010101000",
            "1110101100", "0011100111", "0001011101",
            "0001110011"
        ],
        11: [
            "10111011100", "10101110110", "11100100011",
            "01000110110", "11011011000", "00010001100",
            "10111000111", "11101110001", "10110010111",
            "00010011100", "00111000111"
        ]
    ]
}
