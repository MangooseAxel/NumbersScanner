//
//  TableManipulatorView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 16.03.2023.
//

import SwiftUI

struct TableManipulatorView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
            Stepper("Rows: \(viewModel.rowsCount)", value: $viewModel.rowsCount, in: 1...Int.max)
            Stepper("Columns: \(viewModel.columnsCount)", value: $viewModel.columnsCount, in: 1...Int.max)
        }
    }
}

struct TableManipulatorView_Previews: PreviewProvider {
    static var previews: some View {
        TableManipulatorView(viewModel: .init())
    }
}
