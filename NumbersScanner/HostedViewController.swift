//
//  HostedViewController.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import SwiftUI

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
