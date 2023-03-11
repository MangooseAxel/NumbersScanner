//
//  OCRView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import SwiftUI
import Combine

struct OCRView: UIViewControllerRepresentable {

    @Binding var scannedText: String
    @Binding var scannedNumber: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> OCRScannerViewController {
        let viewController = OCRScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: OCRScannerViewController, context: Context) {}

    class Coordinator: NSObject, GFLiveScannerDelegate {
        func capturedStrings(strings: [String]) {
            print(strings)

            parent.scannedText = "\(strings)"

            guard let scannedText = strings.first,
                  let number = parseNumber(text: scannedText) else { return }

            parent.scannedNumber = "\(number)"
        }

        func liveCaptureEnded(withError: Error?) {
            print(withError ?? "")
        }

        var parent: OCRView

        init(_ parent: OCRView) {
            self.parent = parent
            super.init()
        }

        deinit {
            print("### deinit coordinator")
        }

        private func parseNumber(text: String) -> Int? {
          let acceptedLetters = Array(0...9).map(String.init) + ["-"]

          let characters = text
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

          return Int(String(characters))
        }
    }
}
