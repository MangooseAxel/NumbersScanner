//
//  CGPointExtension.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 10.03.2023.
//

import Foundation

extension CGPoint {
    func distanceTo(point: CGPoint) -> CGFloat {
        sqrt(pow((self.x - point.x), 2) + pow((self.y - point.y), 2))
    }
}
