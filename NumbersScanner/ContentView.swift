//
//  ContentView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import SwiftUI

struct ContentView: View {
    @State var scannedText = ""
    @State var scannedNumber: Int?
    @State var scannerPresented = false
    @StateObject var viewModel = ContentViewModel()
    @FocusState var focusedCell: FocusedCell?

    var body: some View {
        VStack {
            TableManipulatorView(viewModel: viewModel)
            Spacer()
            scannerViewScannedValuesSectionView
            Spacer()
        }
        .sheet(isPresented: $scannerPresented, content: scannerSheetView)
        .padding()
        .toolbar(content: toolbarView)
        .navigationTitle("Number Scanner")
    }

    func toolbarView() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar, content: {
            Button(action: {
                focusedCell = nil
                scannerPresented = true
            }, label: {
                Label("Scan", systemImage: "qrcode.viewfinder")
                    .labelStyle(.titleAndIcon)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            })
            .buttonStyle(.borderedProminent)
        })
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
    }

    func valueCellView(_ row: Int, _ column: Int) -> some View {
        TextField(value: $viewModel.values[row][column], format: .number, label: {})
            .multilineTextAlignment(.center)
            .keyboardType(.numbersAndPunctuation)
            .frame(minWidth: 30, minHeight: 50)
            .scenePadding(.minimum, edges: .horizontal)
            .focused($focusedCell, equals: FocusedCell(row: row, column: column))
            .border(
                isCellSelected(row, column) ? Color.accentColor : .secondary,
                width: isCellSelected(row, column) ? 2 : 1
            )
            .onTapGesture {}
            .onSubmit(hideKeyboard)
            .id("\(row) \(column)")
    }

    func isCellSelected(_ row: Int, _ column: Int) -> Bool {
        focusedCell == FocusedCell(row: row, column: column)
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
        ForEach(ColorScheme.allCases, id: \.self, content: { colorScheme in
            NavigationStack {
                ContentView()
                    .preferredColorScheme(colorScheme)

            }
        })
    }
}
