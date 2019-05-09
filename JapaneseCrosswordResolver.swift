
final class JapaneseCrosswordResolver {

    enum Item: String, CustomDebugStringConvertible {
        case fill = "1"
        case empty = " "
        case unknown = "0"

        public var debugDescription: String {
            return rawValue
        }
    }

    private class Part {
        let startIndex: Int
        let count: Int
        var endIndex: Int {
            return startIndex + count
        }

        init(startIndex: Int, count: Int) {
            self.startIndex = startIndex
            self.count = count
        }
    }

    private var rowVariantsCache: [Int: [[Item]]] = [:]
    private var columnVariantsCache: [Int: [[Item]]] = [:]

    private func findAllVariants(rawParts: [Int], count: Int) -> [[Item]] {
        var parts: [Part] = []
        rawParts.forEach { rawPart in
            let startIndex: Int
            if let lastPart = parts.last {
                startIndex = lastPart.endIndex + 1
            } else {
                startIndex = 0
            }
            parts.append(Part(startIndex: startIndex, count: rawPart))
        }

        var variants: [[Part]] = []

        var queue: [[Part]] = [parts]

        var existVariants: Set<String> = []

        while !queue.isEmpty {
            let variant = queue[0]
            queue.remove(at: 0)

            let key = variant.map({ String($0.startIndex) }).joined(separator: "-")
            if existVariants.contains(key) {
                continue
            }
            existVariants.insert(key)

            variants.append(variant)

            variant.enumerated().forEach { index, part in

                let rightPart = index + 1 < variant.count ? variant[index + 1] : nil

                var mayBeMoveToRight = false
                if let rightPart = rightPart {
                    mayBeMoveToRight = part.endIndex + 1 < rightPart.startIndex
                } else {
                    mayBeMoveToRight = part.endIndex + 1 <= count
                }

                if mayBeMoveToRight {
                    var modifiedVariant = variant.map({ Part(startIndex: $0.startIndex, count: $0.count) })
                    modifiedVariant[index] = Part(startIndex: part.startIndex + 1, count: part.count)
                    queue.append(modifiedVariant)
                }
            }
        }

        var result: [[Item]] = []

        variants.forEach { variant in
            var resultRow = Array(repeating: Item.empty, count: count)

            variant.forEach { part in
                for i in 0..<part.count {
                    resultRow[part.startIndex + i] = Item.fill
                }
            }

            result.append(resultRow)
        }

        return result
    }


    private func mergeAllVariants(_ allVariables: [[Item]], existRow: [Item]) -> [Item]? {
        let validRows = allVariables.filter { row in
            var valid = true
            row.enumerated().forEach { index, value in
                if existRow[index] == Item.unknown {
                    return
                }

                if existRow[index] != value {
                    valid = valid && false
                }
            }
            return valid
        }

        if validRows.isEmpty {
            return nil
        }

        var resultRow = validRows.first!
        validRows.forEach { row in
            row.enumerated().forEach { index, value in
                if resultRow[index] != value {
                    resultRow[index] = Item.unknown
                }
            }
        }

        return resultRow
    }

    func resolve(x: [[Int]], y: [[Int]]) -> [[Item]] {
        var solution: [[Item]] = Array(repeating: Array(repeating: Item.unknown, count: x.count),
                                       count: y.count)

        func getRow(index: Int) -> [Item] {
            return solution[index]
        }

        func setRow(_ row: [Item], index: Int) -> Bool {
            solution.remove(at: index)
            solution.insert(row, at: index)
            return row.contains(.unknown)
        }

        func getColumn(index: Int) -> [Item] {
            var existColumn: [Item] = []
            solution.forEach { solutionRow in
                existColumn.append(solutionRow[index])
            }
            return existColumn
        }

        func setColumn(_ column: [Item], index: Int) -> Bool {
            var containsUnknown = false
            column.enumerated().forEach { solutionRowIndex, value in
                solution[solutionRowIndex][index] = value
                containsUnknown = containsUnknown || value == .unknown
            }
            return containsUnknown
        }

        var n: Int = 0
        var solutionComplete = false
        while !solutionComplete {

            var containsUnknownInRow = false

            for (index, rawPartsRow) in y.enumerated() {
                let allVariables = rowVariantsCache[index] ?? findAllVariants(rawParts: rawPartsRow, count: x.count)
                rowVariantsCache[index] = allVariables
                let existRow: [Item] = getRow(index: index)
                if let resultRow = mergeAllVariants(allVariables, existRow: existRow) {
                    containsUnknownInRow = setRow(resultRow, index: index)
                }
            }

            var containsUnknownInColumn = false

            for (index, rawPartsColumn) in x.enumerated() {
                let allVariables = columnVariantsCache[index] ?? findAllVariants(rawParts: rawPartsColumn, count: y.count)
                columnVariantsCache[index] = allVariables
                let existColumn: [Item] = getColumn(index: index)
                if let resultRow = mergeAllVariants(allVariables, existRow: existColumn) {
                    containsUnknownInColumn = setColumn(resultRow, index: index)
                }
            }

            solutionComplete = !containsUnknownInColumn && !containsUnknownInRow
        }

        return solution
    }
}
