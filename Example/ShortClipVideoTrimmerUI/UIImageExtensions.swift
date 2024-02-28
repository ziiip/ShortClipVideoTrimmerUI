//
//  UIImageExtensions.swift
//  
//
//  Created by Blade on 2024/1/11.
//

import UIKit
public extension UIImage {
  /// SwifterSwift: Create UIImage from color and size.
  ///
  /// - Parameters:
  ///   - color: image fill color.
  ///   - size: image size.
  convenience init(color: UIColor, size: CGSize) {
#if os(watchOS)
    UIGraphicsBeginImageContextWithOptions(size, false, 1)
    defer { UIGraphicsEndImageContext() }

    color.setFill()
    UIRectFill(CGRect(origin: .zero, size: size))

    guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
      self.init()
      return
    }

    self.init(cgImage: aCgImage)
#else
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    guard let image = UIGraphicsImageRenderer(size: size, format: format).image(actions: { context in
      color.setFill()
      context.fill(context.format.bounds)
    }).cgImage else {
      self.init()
      return
    }
    self.init(cgImage: image)
#endif
  }
}
