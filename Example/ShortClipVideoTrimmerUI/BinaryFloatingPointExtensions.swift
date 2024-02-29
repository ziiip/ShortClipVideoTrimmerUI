//
//  BinaryFloatingPointExtensions.swift
//  ShortClipVideoTrimmerUI_Example
//
//  Created by Blade on 2024/2/28, from SwifterSwift.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#if canImport(Foundation)
import Foundation

// MARK: - Methods

public extension BinaryFloatingPoint {
    #if canImport(Foundation)
    /// SwifterSwift: Returns a rounded value with the specified number of decimal places and rounding rule. If
    /// `numberOfDecimalPlaces` is negative, `0` will be used.
    ///
    ///     let num = 3.1415927
    ///     num.rounded(numberOfDecimalPlaces: 3, rule: .up) -> 3.142
    ///     num.rounded(numberOfDecimalPlaces: 3, rule: .down) -> 3.141
    ///     num.rounded(numberOfDecimalPlaces: 2, rule: .awayFromZero) -> 3.15
    ///     num.rounded(numberOfDecimalPlaces: 4, rule: .towardZero) -> 3.1415
    ///     num.rounded(numberOfDecimalPlaces: -1, rule: .toNearestOrEven) -> 3
    ///
    /// - Parameters:
    ///   - numberOfDecimalPlaces: The expected number of decimal places.
    ///   - rule: The rounding rule to use.
    /// - Returns: The rounded value.
    func rounded(numberOfDecimalPlaces: Int, rule: FloatingPointRoundingRule) -> Self {
        let factor = Self(pow(10.0, Double(max(0, numberOfDecimalPlaces))))
        return (self * factor).rounded(rule) / factor
    }
    #endif
}

#endif