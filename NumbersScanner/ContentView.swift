//
//  ContentView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import SwiftUI

struct ContentView: View {
    @State var scannedText = ""
    @State var scannerPresented = false

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
        }
        .sheet(isPresented: $scannerPresented, onDismiss: {
            scannerPresented = false
        }, content: {
            VStack {
                OCRView(scannedText: $scannedText)
                    .frame(height: 200)
                    .padding()

                Spacer()

                Text(scannedText)
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
