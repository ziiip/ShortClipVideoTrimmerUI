//
//  CGRect+Extension.swift
//  Pods-ShortClipVideoTrimmerUI_Example
//
//  Created by Blade on 2024/1/12.
//

import Foundation

extension CGRect {
    var topRight: CGPoint { CGPoint(x: maxX, y: minY) }
    var topLeft: CGPoint { CGPoint(x: minX, y: minY) }
    var bottomRight: CGPoint { CGPoint(x: maxX, y: maxY) }
    var bottomLeft: CGPoint { CGPoint(x: minX, y: maxY) }
}
