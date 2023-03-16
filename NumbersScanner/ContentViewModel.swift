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
    @Published var values: [[Int?]]

    init(rowsCount: Int = 4, columnsCount: Int = 4) {
        self.rowsCount = rowsCount
        self.columnsCount = columnsCount
        self.values = Array(repeating: Array(repeating: nil, count: columnsCount), count: rowsCount)
    }
}
