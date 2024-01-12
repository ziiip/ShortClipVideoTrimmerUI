//
//  CustomBorderView.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Blade on 2024/1/12.
//

import Foundation

class CustomBorderView: UIView  {
    // this allows us to use the "base" layer as a shape layer
    //  instead of adding a sublayer
    lazy var shapeLayer: CAShapeLayer = self.layer as! CAShapeLayer

//    private(set) var customRadius = 10.0
    var customBorderWidth = 1.0 {
        didSet {
            shapeLayer.lineWidth = customBorderWidth
            setNeedsLayout()
        }
    }

    var customBorderColor: UIColor = .black {
        didSet {
            shapeLayer.strokeColor = customBorderColor.cgColor
            setNeedsLayout()
        }
    }

    var customBorderEdges: UIRectEdge = .all {
        didSet {
            setNeedsLayout()
        }
    }

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() {
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let lineWidth = shapeLayer.lineWidth

        let pth = CGMutablePath()

        if customBorderEdges.contains(.top) {
            let transform = CGAffineTransform(translationX: 0, y: lineWidth / 2.0)
            pth.move(to: bounds.topLeft.applying(transform))
            pth.addLine(to: bounds.topRight.applying(transform))
        }

        if customBorderEdges.contains(.right) {
            let transform = CGAffineTransform(translationX: -lineWidth / 2.0, y: 0)
            pth.move(to: bounds.topRight.applying(transform))
            pth.addLine(to: bounds.bottomRight.applying(transform))
        }

        if customBorderEdges.contains(.bottom) {
            let transform = CGAffineTransform(translationX: 0, y: -lineWidth / 2.0)
            pth.move(to: bounds.bottomRight.applying(transform))
            pth.addLine(to: bounds.bottomLeft.applying(transform))
        }

        if customBorderEdges.contains(.left) {
            let transform = CGAffineTransform(translationX: lineWidth / 2.0, y: 0)
            pth.move(to: bounds.bottomLeft.applying(transform))
            pth.addLine(to: bounds.topLeft.applying(transform))
        }

        shapeLayer.path = pth
    }
}
