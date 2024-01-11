//
//  HandleView.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Sagar on 9/23/22.
//

import UIKit

class HandlerView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let dx: CGFloat = -20
        let dy: CGFloat = -20
        let hitFrame = bounds.insetBy(dx: dx, dy: dy)
        let leftHandleView = superview?.viewWithTag(-1000)
        let rightHandleView = superview?.viewWithTag(-2000)
        
        // For click the intersection part
        let hitFrameOfLeftHandle = leftHandleView?.frame.insetBy(dx: dx, dy: dy) ?? .zero
        let hitFrameOfRightHandle = rightHandleView?.frame.insetBy(dx: dx, dy: dy) ?? .zero
        let intersection = hitFrameOfLeftHandle.intersection(hitFrameOfRightHandle)
        let pointInSuper = self.convert(point, to: self.superview)
        if intersection.width > 0, intersection.contains(pointInSuper) {
            if pointInSuper.x <= intersection.midX {
                return leftHandleView ?? self
            } else {
                return rightHandleView ?? self
            }
        }

        let locationByLeftHandleView = self.convert(point, to: leftHandleView)
        let locationByRightHandleView = self.convert(point, to: rightHandleView)
        let locationByThubnailView = self.convert(point, to: superview?.superview)

        if hitFrame.contains(point) {
            return self
        } else if let leftHandleView = leftHandleView, leftHandleView.bounds.insetBy(dx: dx, dy: dy).contains(locationByLeftHandleView) == true {
            return leftHandleView
        } else if let rightHandleView = rightHandleView,  rightHandleView.bounds.insetBy(dx: dx, dy: dy).contains(locationByRightHandleView) == true {
            return rightHandleView
        } else if let _ = superview?.superview?.subviews[0].bounds.contains(locationByThubnailView) {
            
            return superview?.superview?.subviews[0]
        }
        else {
            return nil
        }
    }
    
}
