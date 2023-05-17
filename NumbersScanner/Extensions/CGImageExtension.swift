//
//  CGImageExtension.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 08.03.2023.
//

import UIKit

extension CGImage {
    func cropTo(rect: CGRect) -> CGImage? {
        let imageWidth = CGFloat(self.width)
        let imageHeight = CGFloat(self.height)

        let croppedImage = self.cropping(to: CGRect(
            x: rect.origin.x * imageWidth,
            y: rect.origin.y * imageHeight,
            width: rect.width * imageWidth,
            height: rect.height * imageHeight
        ))

        return croppedImage
    }
}
