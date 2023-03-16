//
//  NumbersScannerApp.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import SwiftUI

@main
struct NumbersScannerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let windowScenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScenes.windows.first else { return }

        let tapGesture = AnyGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        tapGesture.name = "MyTapGesture"
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}

class AnyGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        //
        //        if touches.first?.view is UITextField {
        //            state = .cancelled
        //
        //        } else if let touchedView = touches.first?.view, touchedView is UIControl {
        //            if touchedView is UIStepper {
        //                super.touchesBegan(touches, with: event)
        //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                    self.state = .began
        //                }
        //            } else {
        //                state = .cancelled
        //            }
        //
        //        } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
        //            state = .cancelled
        //
        //        } else {
        //            state = .cancelled
        //            super.touchesBegan(touches, with: event)
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                self.state = .began
        //            }
        //        }

        guard let touchedView = touches.first?.view else {
            state = .cancelled
            super.touchesBegan(touches, with: event)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.state = .began
            }
            return
        }

        switch true {
                case touchedView is UITextView:
            state = .cancelled
        case touchedView is UIStepper:
            super.touchesBegan(touches, with: event)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.state = .began
            }
        case touchedView is UIControl:
            state = .cancelled
        default:
            state = .cancelled
            super.touchesBegan(touches, with: event)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.state = .began
            }
        }

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}
