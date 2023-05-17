//
//  ContentViewModel.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 16.03.2023.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var rowsCount: Int
    {
        willSet {
            if newValue > rowsCount {
                values.append(.init(repeating: nil, count: columnsCount))
            } else {
                values.removeLast()
            }
        }
    }
    @Published var columnsCount: Int
    {
        willSet {
            if newValue > columnsCount {
                values.indices.forEach { rowIndex in
                    values[rowIndex].append(nil)
                }
            } else {
                values.indices.forEach { rowIndex in
                    values[rowIndex].removeLast()
                }
            }
        }
    }
    @Published var values: [[Double?]]

    let tempFileURL: URL

    init(rowsCount: Int = 4, columnsCount: Int = 4) {
        self.rowsCount = rowsCount
        self.columnsCount = columnsCount
        self.values = [[0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3]]

        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        tempFileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("csv")
    }

    func isCSVAvailable() -> Bool {
        do {
            let tmpValues = [Array(repeating: 0.0, count: values.first?.count ?? 1)] + values

            let csvBodyString = tmpValues.map({ row in
                row.enumerated().map({ index, value in
                    if row == tmpValues.first {
                        return index == 0 ? "x" : "y\(index)"
                    } else {
                        if let value {
                            return "\(value)"
                        } else {
                            return ""
                        }
                    }
                }).joined(separator: ",")
            }).joined(separator: "\n")

            try String(csvBodyString).write(to: tempFileURL, atomically: true, encoding: .utf8)

            return true
        } catch {
            print(error)
            return false
        }
    }
}
