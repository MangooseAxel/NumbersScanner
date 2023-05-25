//
//  OCRScannerView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import SwiftUI
import Combine

struct OCRScannerView: UIViewControllerRepresentable {

    @Binding var scannedText: String
    @Binding var scannedNumber: Double?

    func makeUIViewController(context: Context) -> OCRScannerViewController {
        let viewController = OCRScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: OCRScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GFLiveScannerDelegate {
        var parent: OCRScannerView

        init(_ parent: OCRScannerView) {
            self.parent = parent
            super.init()
        }

        func capturedString(_ string: String) {
            parent.scannedText = "\(string)"

            if let number = parseNumber(text: string) {
                parent.scannedNumber = number
            }
        }

        private func parseNumber(text: String) -> Double? {
            let acceptedLetters = Array(0...9).map(String.init) + ["-"] + [","] + ["."]

            let characters = text
                .replacingOccurrences(of: ",", with: ".")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "o", with: "0")
                .replacingOccurrences(of: "|", with: "1")
                .replacingOccurrences(of: "l", with: "1")
                .replacingOccurrences(of: "L", with: "1")
                .replacingOccurrences(of: "z", with: "2")
                .replacingOccurrences(of: "Z", with: "2")
                .replacingOccurrences(of: "s", with: "2")
                .replacingOccurrences(of: "S", with: "2")
                .filter({ acceptedLetters.contains(String($0)) })

            return Double(characters)
        }
    }
}
