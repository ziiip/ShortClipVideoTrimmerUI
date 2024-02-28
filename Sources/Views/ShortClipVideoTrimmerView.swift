//
//  ShortClipVideoTrimmerView.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Sagar on 9/23/22.
//

import UIKit
import AVFoundation

protocol ShortClipVideoTrimmerViewDelegate: AnyObject {
    func handlerPanningStateChange(_ isLeft: Bool, _ panningState: UIGestureRecognizer.State)
    func didLeftHandleLeadingPositionChange(leadingConstraint : CGFloat?)
    func didRightHandleLeadingPositionChange(leadingConstraint : CGFloat?)
}


class ShortClipVideoTrimmerView: UIView {
    
    // all SubViews
    private let trimView = UIView()
    private let trimViewBorderView = CustomBorderView()
    private let leftHandleView = HandlerView()
    private let rightHandleView = HandlerView()
    private let positionBar = UIView()
    private let leftHandleKnob = UIView()
    private let rightHandleKnob = UIView()
    private let leftMaskView = UIView()
    private let rightMaskView = UIView()    
    // constraints
    var trimViewLeftConstraint : NSLayoutConstraint?
    var trimViewRightConstraint : NSLayoutConstraint?
    var trimViewTopConstraint : NSLayoutConstraint?
    var trimViewBottomConstraint : NSLayoutConstraint?
    var leftHandlerWidthConstraint : NSLayoutConstraint?
    var rightHandlerWidthConstraint: NSLayoutConstraint?
    
    var positionBarWidthConstraint : NSLayoutConstraint?
    var positionBarLeftConstraint : NSLayoutConstraint?
    var leftKnobWidthConstraint : NSLayoutConstraint?
    var rightKnobWidthConstraint : NSLayoutConstraint?
    
    // other attributes
    var outsideTrimBackgroundColor : UIColor = .white {
        didSet {
            self.updateTrimmingOutsidebackgroundColor(color: outsideTrimBackgroundColor)
        }
    }

    var borderEdges : UIRectEdge = [.top, .bottom] {
        didSet {
            self.updateTrimmingAreaBorderEdges(edges: borderEdges)
        }
    }

    var borderColor : UIColor = .blue {
        didSet {
            self.updateTrimmingAreaBorderColor(color: borderColor)
        }
    }

    var trimmerRadius: CGFloat = 4.0 {
        didSet {
            if #available(iOS 11.0, *) {
//                trimView.layer.cornerRadius = self.trimmerRadius
                self.updateHandlerRadiuses(trimmerRadius)
            }
        }
    }

    var handlerColor : UIColor = .blue {
        didSet {
            self.updateHandlerColor(color: handlerColor)
        }
    }
    var knobColor : UIColor = .white {
        didSet {
            self.updateKnobColor(color: knobColor)
        }
    }
    var positionBarColor : UIColor = .white {
        didSet {
            self.updatePositionBarColor(color: positionBarColor)
        }
    }
    
    var borderWidth : CGFloat = 3.0 {
        didSet {
            self.updateTrimmingAreaBorderWidth(width: borderWidth)
        }
    }
    
    var handlerWidth : CGFloat = 15.0 {
        didSet {
            self.updateHandlerWidthConstraint(width: handlerWidth)
        }
    }
    
    var knobWidth : CGFloat = 3 {
        didSet {
            self.updateKnobWidthConstraints(width: knobWidth)
        }
    }
    
    var positionBarWidth : CGFloat = 4 {
        didSet {
            self.updatePositionBarWidthConstraints(width: positionBarWidth)
        }
    }
    
    var maskAlpha : CGFloat = 0.5 {
        didSet {
            updateTrimmingOutsideMaskVisibility(alpha: maskAlpha)
        }
    }

    var minimumDistanceBetweenHandler : CGFloat =  3.0
    var horizonInset: CGFloat = 0.0


    // delegate
    weak var delegate : ShortClipVideoTrimmerViewDelegate?
   
    private var currentTrimLeftConstraintValue: CGFloat = 0
    private var currentTrimRightConstraintValue: CGFloat = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public init(frame: CGRect, horizonInset: CGFloat) {
        super.init(frame: frame)
        self.horizonInset = horizonInset
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func updateBackgroundColor(color : UIColor) {
        backgroundColor = color
    }
    
    private func setupViews() {
        backgroundColor = .clear
        layer.masksToBounds = false
        clipsToBounds = false
        setupTrimView()
        setupHandlerViews()
        setupMaskView()
        setupPositionBar()
        setupGestures()
        updateHandlerColor(color: handlerColor)
        updateTrimmingAreaBorderEdges(edges: borderEdges)
        updateTrimmingAreaBorderColor(color: borderColor)
        updateTrimmingAreaBorderWidth(width: borderWidth)
        updateKnobColor(color: knobColor)
        updatePositionBarColor(color: positionBarColor)
        updateTrimmingOutsidebackgroundColor(color: outsideTrimBackgroundColor)
        updateTrimmingOutsideMaskVisibility(alpha: maskAlpha)
    }
    
    private func setupTrimView() {
        
        trimView.translatesAutoresizingMaskIntoConstraints = false
        trimView.isUserInteractionEnabled = false
        trimView.clipsToBounds = true
        addSubview(trimView)
        trimViewLeftConstraint = trimView.leftAnchor.constraint(equalTo: leftAnchor)
        trimViewRightConstraint = trimView.rightAnchor.constraint(equalTo: rightAnchor)
        trimViewLeftConstraint?.isActive = true
        trimViewRightConstraint?.isActive = true
        trimViewTopConstraint = trimView.topAnchor.constraint(equalTo: topAnchor)
        trimViewBottomConstraint = trimView.bottomAnchor.constraint(equalTo: bottomAnchor)
        trimViewTopConstraint?.isActive = true
        trimViewBottomConstraint?.isActive = true

        trimViewBorderView.translatesAutoresizingMaskIntoConstraints = false
        trimViewBorderView.isUserInteractionEnabled = false
        trimView.addSubview(trimViewBorderView)
        NSLayoutConstraint.activate([
            trimViewBorderView.topAnchor.constraint(equalTo: trimView.topAnchor),
            trimViewBorderView.rightAnchor.constraint(equalTo: trimView.rightAnchor),
            trimViewBorderView.bottomAnchor.constraint(equalTo: trimView.bottomAnchor),
            trimViewBorderView.leftAnchor.constraint(equalTo: trimView.leftAnchor)
        ])

        trimView.layoutIfNeeded()
    }
    
    private func setupHandlerViews() {
        setupLeftHandlerView()
        setupRightHandlerView()
    }
    
    private func setupLeftHandlerView() {
        leftHandleView.isUserInteractionEnabled = true
        leftHandleView.translatesAutoresizingMaskIntoConstraints = false
        leftHandleView.layer.cornerRadius = 2.0
        leftHandleView.tag = -1000
        addSubview(leftHandleView)
        leftHandlerWidthConstraint = leftHandleView.widthAnchor.constraint(equalToConstant: handlerWidth)
        leftHandlerWidthConstraint?.isActive = true
        NSLayoutConstraint.activate([
            leftHandleView.topAnchor.constraint(equalTo: trimView.topAnchor),
            leftHandleView.rightAnchor.constraint(equalTo: trimView.leftAnchor, constant: 0),
            leftHandleView.heightAnchor.constraint(equalTo: trimView.heightAnchor)
        ])
        
        leftHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        leftHandleKnob.backgroundColor = knobColor
        leftHandleView.addSubview(leftHandleKnob)
        leftKnobWidthConstraint =  leftHandleKnob.widthAnchor.constraint(equalToConstant: knobWidth)
        leftKnobWidthConstraint?.isActive = true
        NSLayoutConstraint.activate([
            leftHandleKnob.centerYAnchor.constraint(equalTo: leftHandleView.centerYAnchor),
            leftHandleKnob.centerXAnchor.constraint(equalTo: leftHandleView.centerXAnchor),
            leftHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupRightHandlerView() {
        rightHandleView.isUserInteractionEnabled = true
        rightHandleView.translatesAutoresizingMaskIntoConstraints = false
        rightHandleView.layer.cornerRadius = 2.0
        rightHandleView.tag = -2000
        addSubview(rightHandleView)
        rightHandlerWidthConstraint = rightHandleView.widthAnchor.constraint(equalToConstant: handlerWidth)
        rightHandlerWidthConstraint?.isActive = true
        NSLayoutConstraint.activate([
            rightHandleView.topAnchor.constraint(equalTo: trimView.topAnchor),
            rightHandleView.leftAnchor.constraint(equalTo: trimView.rightAnchor, constant: 0),
            rightHandleView.heightAnchor.constraint(equalTo: trimView.heightAnchor)
        ])
        rightHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        rightHandleView.addSubview(rightHandleKnob)
        
        rightKnobWidthConstraint = rightHandleKnob.widthAnchor.constraint(equalToConstant: knobWidth)
        rightKnobWidthConstraint?.isActive = true
        NSLayoutConstraint.activate([
            rightHandleKnob.centerYAnchor.constraint(equalTo: rightHandleView.centerYAnchor),
            rightHandleKnob.centerXAnchor.constraint(equalTo: rightHandleView.centerXAnchor),
            rightHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupMaskView() {
        leftMaskView.isUserInteractionEnabled = false
        leftMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(leftMaskView, belowSubview: leftHandleView)
        
        leftMaskView.leftAnchor.constraint(equalTo: leftAnchor, constant: -self.horizonInset).isActive = true
        leftMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftMaskView.topAnchor.constraint(equalTo: topAnchor, constant:0.0).isActive = true
        leftMaskView.rightAnchor.constraint(equalTo: leftHandleView.rightAnchor, constant: 0).isActive = true
        
        rightMaskView.isUserInteractionEnabled = false
        rightMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rightMaskView, belowSubview: rightHandleView)
        
        rightMaskView.rightAnchor.constraint(equalTo: rightAnchor, constant: self.horizonInset).isActive = true
        rightMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightMaskView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
        rightMaskView.leftAnchor.constraint(equalTo: rightHandleView.leftAnchor, constant: 0).isActive = true
    }
    
    private func setupPositionBar() {
        
        positionBar.center = CGPoint(x: leftHandleView.frame.maxX, y: center.y)
        positionBar.layer.cornerRadius = 1
        positionBar.translatesAutoresizingMaskIntoConstraints = false
        positionBar.isUserInteractionEnabled = false
        addSubview(positionBar)
        
        positionBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        positionBarWidthConstraint = positionBar.widthAnchor.constraint(equalToConstant: positionBarWidth)
        positionBarLeftConstraint = positionBar.leftAnchor.constraint(equalTo: leftHandleView.rightAnchor, constant: 0)
        positionBar.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        positionBarLeftConstraint?.isActive = true
        positionBarWidthConstraint?.isActive = true
    }
    
    private func setupGestures() {
        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        leftHandleView.addGestureRecognizer(leftPanGestureRecognizer)
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        rightPanGestureRecognizer.require(toFail: leftPanGestureRecognizer)
        rightHandleView.addGestureRecognizer(rightPanGestureRecognizer)
    }
    
}

extension ShortClipVideoTrimmerView {
    func updateMinimumTrimScale(_ scale: CGFloat) {
        self.minimumDistanceBetweenHandler = max(.zero, self.frame.width * scale)
    }
    func updateTrimmingOutsidebackgroundColor(color : UIColor) {
        leftMaskView.backgroundColor = color
        rightMaskView.backgroundColor = color
    }
    
    func updateTrimmingOutsideMaskVisibility(alpha : CGFloat) {
        leftMaskView.alpha = alpha
        rightMaskView.alpha = alpha
    }
    
    func updatePositionBarColor(color : UIColor) {
        positionBar.backgroundColor = color
    }
    
    func updateHandlerColor(color : UIColor) {
        leftHandleView.backgroundColor = color
        rightHandleView.backgroundColor = color
    }

    func customizingHandleView(_ customizing: (UIView, UIView) -> Void) {
        customizing(leftHandleView, rightHandleView)
    }

    @available(iOS 11.0, *)
    func updateHandlerRadiuses(_ radius: CGFloat) {
        leftHandleView.layer.cornerRadius = radius
        leftHandleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        if #available(iOS 13.0, *) {
            leftHandleView.layer.cornerCurve = .continuous
        }

        rightHandleView.layer.cornerRadius = radius
        rightHandleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        if #available(iOS 13.0, *) {
            rightHandleView.layer.cornerCurve = .continuous
        }
    }

    private func updateTrimmingAreaBorderEdges(edges : UIRectEdge) {
        self.trimViewBorderView.customBorderEdges = edges
    }

    private func updateTrimmingAreaBorderColor(color : UIColor) {
        self.trimViewBorderView.customBorderColor = color
    }
    
    private func updateKnobColor(color : UIColor) {
        leftHandleKnob.backgroundColor = color
        rightHandleKnob.backgroundColor = color
    }
    
    private func updateTrimmingAreaBorderWidth(width : CGFloat) {
        self.trimViewBorderView.customBorderWidth = width
        self.trimViewTopConstraint?.constant = -width
        self.trimViewBottomConstraint?.constant = width
    }
    
    private func updateHandlerWidthConstraint(width : CGFloat) {
        if let leftHandlerWidthConstraint = leftHandlerWidthConstraint {
            leftHandlerWidthConstraint.constant = width
        }
        if let rightHandlerWidthConstraint = rightHandlerWidthConstraint {
            rightHandlerWidthConstraint.constant = width
        }
    }
    
    private func updateKnobWidthConstraints(width : CGFloat) {
        if let leftKnobWidthConstraint = leftKnobWidthConstraint, let rightKnobWidthConstraint = rightKnobWidthConstraint {
            leftKnobWidthConstraint.constant = width
            rightKnobWidthConstraint.constant = width
        }
    }
    
    private func updatePositionBarWidthConstraints(width : CGFloat) {
        if let  positionBarWidthConstraint =  positionBarWidthConstraint {
            positionBarWidthConstraint.constant = width
        }
    }
    
    func resetPositionBarConstraints() {
        positionBarLeftConstraint?.constant = 0.0
        layoutIfNeeded()
    }
    
    func resetHandleViewPosition() {
        trimViewLeftConstraint?.constant = 0
        trimViewRightConstraint?.constant = 0
        layoutIfNeeded()
    }
    
}
//
extension ShortClipVideoTrimmerView {
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view, let superView = gestureRecognizer.view?.superview else { return }
        let isLeftGesture = view == leftHandleView
        
        self.delegate?.handlerPanningStateChange(isLeftGesture, gestureRecognizer.state)

        switch gestureRecognizer.state {
            
        case .began:
            if isLeftGesture {
                currentTrimLeftConstraintValue = trimViewLeftConstraint!.constant
            } else {
                currentTrimRightConstraintValue = trimViewRightConstraint!.constant
            }
        case .changed:
            let translation = gestureRecognizer.translation(in: superView)
            if isLeftGesture {
                updateLeftConstraint(with: translation)
            } else {
                updateRightConstraint(with: translation)
            }
            layoutIfNeeded()
            
        case .cancelled, .ended, .failed:
            break
        default:
            break
        }
    }
    
    public func updateLeftConstraint(with translation: CGPoint, reset: Bool = false, updateDelegate: Bool = false) {
        let maxConstraint = max(rightHandleView.frame.origin.x - minimumDistanceBetweenHandler, 0)
        let newConstraint = min(max(0, (reset ? 0 : currentTrimLeftConstraintValue) + translation.x), maxConstraint)
        trimViewLeftConstraint?.constant = newConstraint
        delegate?.didLeftHandleLeadingPositionChange(leadingConstraint: newConstraint)
    }
    
    public func updateRightConstraint(with translation: CGPoint, reset: Bool = false, updateDelegate: Bool = false) {
        let prevRightConstraint = trimViewRightConstraint?.constant
        var leadingConstraint = rightHandleView.frame.origin.x
        let maxConstraint = min(0, -(frame.width - leftHandleView.frame.origin.x - (1 * handlerWidth) - minimumDistanceBetweenHandler))
        let newConstraint = max(min(0, (reset ? 0 : currentTrimRightConstraintValue) + translation.x), maxConstraint)
        trimViewRightConstraint?.constant = newConstraint //+ handleWidth
        if let prevRightConstraint = prevRightConstraint {
            let increased = newConstraint - prevRightConstraint
            leadingConstraint += increased
        }
        
        delegate?.didRightHandleLeadingPositionChange(leadingConstraint: frame.width + newConstraint)
    }

    public func seek(to time: CMTime, startTime : CGFloat, finishTime : CGFloat, delayBetweenFrames : CGFloat) {
        if (startTime >= finishTime || delayBetweenFrames == 0) {
            positionBarLeftConstraint?.constant = 0.0
            layoutIfNeeded()
            return
        }
        let currentSeconds = CGFloat(time.seconds)
        let durationOfArea = finishTime - startTime
        let timeMovingDifference = currentSeconds - startTime
        let visibleAreaWidth = rightHandleView.frame.origin.x - (leftHandleView.frame.origin.x + handlerWidth)
        - positionBar.frame.width
        let distance = max(0, (visibleAreaWidth * timeMovingDifference) / durationOfArea)
        positionBarLeftConstraint?.constant = distance
        layoutIfNeeded()
    }
}

extension ShortClipVideoTrimmerView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let leftHandleView = superview?.viewWithTag(-1000)
        let rightHandleView = superview?.viewWithTag(-2000)

        func viewWithPoint(_ view: UIView?, point: CGPoint, with event: UIEvent?, viewOfPoint: UIView) -> UIView? {
            let pointToView = viewOfPoint.convert(point, to: view)
            guard let view = view,
               let view = view.hitTest(pointToView, with: event) else  {
                return nil
            }
            return view
        }

        if let view = viewWithPoint(leftHandleView, point: point, with: event, viewOfPoint: self) {
            return view
        } else if let view = viewWithPoint(rightHandleView, point: point, with: event, viewOfPoint: self) {
            return view
        }

        return super.hitTest(point, with: event)
    }
}
