//
//  ScannerSheetView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 12.03.2023.
//

import SwiftUI

struct FocusedCell: Hashable {
    let row: Int
    let column: Int
}

struct ScannerSheetView: View {
    @Binding var scannedText: String
    @Binding var scannedNumber: Double?
    @ObservedObject var viewModel: ContentViewModel
    @State private var selectedCell: FocusedCell = .init(row: 0, column: 0)

    init(scannedText: Binding<String>, scannedNumber: Binding<Double?>, viewModel: ContentViewModel) {
        self._scannedText = scannedText
        self._scannedNumber = scannedNumber
        self.viewModel = viewModel

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
                .frame(height: 170)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))

            TableManipulatorView(viewModel: viewModel)
                .padding(.horizontal)

            scannerViewScannedValuesSectionView
                .toolbar(content: scannerViewToolbar)

            Spacer()
        }
        .padding()
    }

    var scannerViewScannedValuesSectionView: some View {
        GroupBox(content: {
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
                .onChange(of: selectedCell) { _ in
                    withAnimation {
                        scrollProxy.scrollTo(selectedCell, anchor: .center)
                    }
                }
                .onAppear {
                    scrollProxy.scrollTo(selectedCell, anchor: .center)
                }
            }
        })
        .frame(maxHeight: 340, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    func valueCellView(_ row: Int, _ column: Int) -> some View {
        Button(action: {
            selectedCell = .init(row: row, column: column)
        }, label: {
            Text(viewModel.values[row][column]?.formatted() ?? "")
                .frame(minWidth: 30, maxWidth: .infinity, minHeight: 50)
                .scenePadding(.minimum, edges: .horizontal)
                .border(
                    isCellSelected(row, column) ? Color.accentColor : .secondary,
                    width: isCellSelected(row, column) ? 2 : 1
                )
                .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .id(FocusedCell(row: row, column: column))
    }

    func isCellSelected(_ row: Int, _ column: Int) -> Bool {
        selectedCell == .init(row: row, column: column)
    }

    func scannerViewToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar, content: {
            Button(action: {
                viewModel.values[selectedCell.row][selectedCell.column] = scannedNumber

                let newColumn = (selectedCell.column + 1) % (viewModel.values.first?.count ?? 1)
                let newRow = (selectedCell.row + (newColumn == 0 ? 1 : 0)) % viewModel.values.count

                selectedCell = .init(row: newRow, column: newColumn)
            }, label: {
                Label("Insert", systemImage: "plus.viewfinder")
                    .labelStyle(.titleAndIcon)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            })
            .buttonStyle(.borderedProminent)
            .tint(.green)
        })
    }
}

struct ScannerSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self, content: { colorScheme in
            NavigationStack {
                ScannerSheetView(
                    scannedText: .constant(""),
                    scannedNumber: .constant(nil),
                    viewModel: .init()
                )
            }
            .preferredColorScheme(colorScheme)
        })
    }
}
