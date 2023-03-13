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
    @State var scannerPresented = true
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Text("Scanned text")
                .padding()
            Text(scannedText)
                .frame(maxWidth: .infinity)
                .border(.black)

            Button("Start scanning", action: {
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
        }
        .sheet(isPresented: $scannerPresented, content: scannerSheetView)
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
    }
}
