//
//  ViewExtension.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 15.03.2023.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
