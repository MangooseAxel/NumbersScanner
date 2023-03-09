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

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}

    class Coordinator: NSObject, GFLiveScannerDelegate {
        func capturedStrings(strings: [String]) {
            print(strings)
            parent.scannedText = strings.joined(separator: ",")
        }

        func liveCaptureEnded(withError: Error?) {
            print(withError ?? "")
        }

        var parent: OCRView

        init(_ parent: OCRView) {
            self.parent = parent
            super.init()
        }
    }
}
