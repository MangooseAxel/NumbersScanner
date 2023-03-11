//
//  ContentView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import SwiftUI

struct ContentView: View {
    @State var scannedText = ""
    @State var scannedNumber = ""
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
//            NavigationLink("Start scanning", destination: {
//                ZStack {
//                    OCRView(scannedText: $scannedText)
//
//                    Text(scannedText)
//                        .padding()
//                }
//            })
        }
        .sheet(isPresented: $scannerPresented, onDismiss: {
            scannerPresented = false
        }, content: {
            VStack {
                OCRView(scannedText: $scannedText, scannedNumber: $scannedNumber)
                    .frame(height: 200)
                    .padding()

                Spacer()

                List {
                    Section("Text", content: {
                        Text(scannedText)
                    })

                    Section("Number", content: {
                        Text(scannedNumber)
                    })
                }

                Spacer()
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
