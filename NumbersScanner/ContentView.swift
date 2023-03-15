//
//  ContentView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var rowsCount: Int = 4
    @Published var columnsCount: Int = 4
    @Published var selectedCell: (row: Int, column: Int) = (row: 0, column: 0)
    @Published var values: [[Int?]]

    init() {
        self.values = Array(repeating: Array(repeating: nil, count: 10), count: 10)
    }
}

struct ContentView: View {
    @State var scannedText = ""
    @State var scannedNumber: Int?
    @State var scannerPresented = false
    @StateObject var viewModel = ContentViewModel()
    @FocusState var focusedValue: String?

    var body: some View {
        VStack {
            Text("Scanned text")
                .padding()

            Button("Start scanning", action: {
                focusedValue = nil
                scannerPresented = true
            })
//            NavigationLink("Start scanning", destination: {
//                ZStack {
//                    OCRView(scannedText: $scannedText)
//
//                    Text(scannedText)
//                        .padding()
//                }
//            })
            scannerViewScannedValuesSectionView
        }
        .sheet(isPresented: $scannerPresented, content: scannerSheetView)
        .contentShape(Rectangle())
        .onTapGesture(perform: hideKeyboard)
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
                .onAppear {
                    scrollProxy.scrollTo("0 0", anchor: .center)
                }
            }
        }
        .frame(maxHeight: 350, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding()
    }

    func valueCellView(_ row: Int, _ column: Int) -> some View {
        TextField(value: $viewModel.values[row][column], format: .number, label: {})
            .multilineTextAlignment(.center)
            .keyboardType(.numbersAndPunctuation)
            .frame(minWidth: 30, minHeight: 50)
            .scenePadding(.minimum, edges: .horizontal)
            .focused($focusedValue, equals: "\(row) \(column)")
            .border(
                isCellSelected(row, column) ? Color.accentColor : .secondary,
                width: isCellSelected(row, column) ? 2 : 1
            )
            .onTapGesture {}
            .onSubmit(hideKeyboard)
            .id("\(row) \(column)")
    }

    func isCellSelected(_ row: Int, _ column: Int) -> Bool {
        focusedValue == "\(row) \(column)"
    }

    func scannerSheetView() -> ScannerSheetView {
        ScannerSheetView(
            scannedText: $scannedText,
            scannedNumber: $scannedNumber,
            viewModel: viewModel
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)

        ContentView()
            .preferredColorScheme(.light)
    }
}
