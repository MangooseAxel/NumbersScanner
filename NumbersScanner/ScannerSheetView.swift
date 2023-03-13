//
//  ScannerSheetView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 12.03.2023.
//

import SwiftUI

struct ScannerSheetView: View {
    @Binding var scannedText: String
    @Binding var scannedNumber: Int?
    @ObservedObject var viewModel: ContentViewModel
    @State private var scrollTarget: String

    init(scannedText: Binding<String>, scannedNumber: Binding<Int?>, viewModel: ContentViewModel) {
        self._scannedText = scannedText
        self._scannedNumber = scannedNumber
        self.viewModel = viewModel
        self._scrollTarget = State(initialValue: "\(viewModel.selectedCell.row) \(viewModel.selectedCell.column)")

        UITableView.appearance().isScrollEnabled = false
    }

    var body: some View {
        NavigationStack {
            GroupBox {
                ZStack {
                    OCRView(scannedText: $scannedText, scannedNumber: $scannedNumber)

                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Text("Text: ")
                            Text(scannedText)
                        }

                        HStack {
                            Text("Number: ")
                            if let scannedNumber {
                                Text(scannedNumber, format: .number)
                            } else {
                                Text("")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 200)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()

            scannerViewScannedValuesSectionView
                .toolbar(content: scannerViewToolbar)

            Spacer()
        }
    }

    var scannerViewScannedValuesSectionView: some View {
        GroupBox("Scanned values") {
            ScrollViewReader { scrollProxy in
                ScrollView([.vertical, .horizontal]) {
                    Grid {
                        ForEach(viewModel.values.indices, id: \.self) { row in
                            GridRow {
                                ForEach(viewModel.values[row].indices, id: \.self) { column in
                                    valueCellView(row, column)
                                }
                            }
                        }
                    }
                }
                .onChange(of: scrollTarget) { _ in
                    withAnimation {
                        scrollProxy.scrollTo(scrollTarget, anchor: .center)
                    }
                }
                .onAppear {
                    scrollProxy.scrollTo(scrollTarget, anchor: .center)
                }
            }
        }
        .frame(maxHeight: 350, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding()
    }

    func valueCellView(_ row: Int, _ column: Int) -> some View {
        Button(action: {
            viewModel.selectedCell = (row, column)
        }, label: {
            Text(viewModel.values[row][column]?.formatted() ?? "")
                .frame(width: 50, height: 50)
                .border(
                    isCellSelected(row, column) ? .blue : .black,
                    width: isCellSelected(row, column) ? 2 : 1
                )
                .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .id("\(row) \(column)")
    }

    func isCellSelected(_ row: Int, _ column: Int) -> Bool {
        viewModel.selectedCell == (row, column)
    }

    func scannerViewToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar, content: {
            Button(action: {
                let selectedCell = viewModel.selectedCell
                viewModel.values[selectedCell.row][selectedCell.column] = scannedNumber

                let newColumn = (selectedCell.column + 1) % (viewModel.values.first?.count ?? 1)
                let newRow = (selectedCell.row + (newColumn == 0 ? 1 : 0)) % viewModel.values.count

                viewModel.selectedCell = (newRow, newColumn)
                scrollTarget = "\(newRow) \(newColumn)"
            }, label: {
                Text("Insert")
                    .padding(.horizontal, 50)
            })
            .buttonStyle(.borderedProminent)
            .tint(.green)
        })
    }
}

struct ScannerSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerSheetView(
            scannedText: .constant(""),
            scannedNumber: .constant(nil),
            viewModel: .init()
        )
    }
}
