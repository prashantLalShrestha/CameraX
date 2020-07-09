//
//  QuadrilateralView.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

enum CornerPosition {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
}

final class QuadrilateralView: UIView {
    
    private let quadLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 2.0
        layer.opacity = 1.0
        layer.isHidden = true
        layer.fillRule = .evenOdd
        return layer
    }()
    
    private var quadCornerLayer: CAShapeLayer? = nil
    
    private let quadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) var quad: Quadrilateral?
    
    private lazy var topLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topLeft)
    }()
    
    private lazy var topRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topRight)
    }()
    
    private lazy var bottomRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomRight)
    }()
    
    private lazy var bottomLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomLeft)
    }()
    
    private let highlightedCornerViewSize = CGSize(width: 75.0, height: 75.0)
    private let cornerViewSize = CGSize(width: 20.0, height: 20.0)
    
    public var editable = false {
        didSet {
//            cornerViews(hidden: !editable)
            quadLayer.fillColor = editable ? fillColor.cgColor : highlightColor.cgColor
            guard let quad = quad else {
                return
            }
            drawQuad(quad, animated: false)
//            layoutCornerViews(forQuad: quad)
        }
    }
    
    public var isHighlighted = false {
        didSet (oldValue) {
            guard oldValue != isHighlighted else {
                return
            }
            quadLayer.fillColor = isHighlighted ? UIColor.clear.cgColor : fillColor.cgColor
            isHighlighted ? bringSubviewToFront(quadView) : sendSubviewToBack(quadView)
        }
    }
    
    public var isMasked = false {
        didSet (oldValue) {
            guard oldValue != isMasked else {
                return
            }
            quadLayer.fillColor = isMasked ? fillColor.cgColor : highlightColor.cgColor
            isMasked ? bringSubviewToFront(quadView) : sendSubviewToBack(quadView)
        }
    }
    
    public var isSkeleton: Bool = false {
        didSet {
            guard oldValue != isSkeleton else { return }
            quadLayer.fillColor = UIColor.clear.cgColor
            isSkeleton ? bringSubviewToFront(quadView): sendSubviewToBack(quadView)
        }
    }
    
    public var fillColor: UIColor = UIColor(white: 0.0, alpha: 0.6) {
        didSet { }
    }
    public var highlightColor: UIColor = UIColor(white: 1.0, alpha: 0.5) {
        didSet {  }
    }
    public var strokeColor: UIColor = UIColor.white {
        didSet {
            if strokeColor != oldValue {
                quadLayer.strokeColor = strokeColor.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(quadView)
        setupConstraints()
        quadView.layer.addSublayer(quadLayer)
    }
    
    private func setupConstraints() {
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: topAnchor),
            quadView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            trailingAnchor.constraint(equalTo: quadView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(quadViewConstraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard quadLayer.frame != bounds else { return }
        
        quadLayer.frame = bounds
        
        if let quad = quad {
            drawQuadrilateral(quad: quad, animated: false)
        }
    }
    
    func drawQuadrilateral(quad: Quadrilateral, animated: Bool) {
        self.quad = quad
        drawQuad(quad, animated: animated)
    }
    
    private func drawQuad(_ quad: Quadrilateral, animated: Bool) {
        var path = quad.path
        
        if editable || isMasked {
            path = path.reversing()
            let rectPath = UIBezierPath(rect: CGRect(x: bounds.minX - 1.0, y: bounds.minY - 1.0, width: bounds.maxX + 2, height: bounds.maxY + 2))
            path.append(rectPath)
        }
        
        if animated == true {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.duration = 0.2
            quadLayer.add(pathAnimation, forKey: "path")
        }
        
        quadLayer.path = path.cgPath
        quadLayer.isHidden = false
    }
    
    func removeQuadrilateral() {
        quadLayer.path = nil
        quadLayer.isHidden = true
        quadCornerLayer?.removeFromSuperlayer()
    }
    
    func addCornerLines() {
        guard let quad = quad else { return }
        self.quadCornerLayer = quad.cornerLayer
        quadCornerLayer?.removeFromSuperlayer()
        quadLayer.addSublayer(self.quadCornerLayer!)
    }
}


// MARK: - Editing Corners Functions
extension QuadrilateralView {
    
    
    private func layoutCornerViews(forQuad quad: Quadrilateral) {
        topLeftCornerView.center = quad.topLeft
        topRightCornerView.center = quad.topRight
        bottomLeftCornerView.center = quad.bottomLeft
        bottomRightCornerView.center = quad.bottomRight
    }
    
    // MARK: - Actions
    
    func moveCorner(cornerView: EditScanCornerView, atPoint point: CGPoint) {
        guard let quad = quad else {
            return
        }
        
        let validPoint = self.validPoint(point, forCornerViewOfSize: cornerView.bounds.size, inView: self)
        
        cornerView.center = validPoint
        let updatedQuad = update(quad, withPosition: validPoint, forCorner: cornerView.position)
        
        self.quad = updatedQuad
        drawQuad(updatedQuad, animated: false)
    }
    
    func highlightCornerAtPosition(position: CornerPosition, with image: UIImage) {
        guard editable else {
            return
        }
        isHighlighted = true
        
        let cornerView = cornerViewForCornerPosition(position: position)
        guard cornerView.isHighlighted == false else {
            cornerView.highlightWithImage(image)
            return
        }

        let origin = CGPoint(x: cornerView.frame.origin.x - (highlightedCornerViewSize.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y - (highlightedCornerViewSize.height - cornerViewSize.height) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: highlightedCornerViewSize)
        cornerView.highlightWithImage(image)
    }
    
    func resetHighlightedCornerViews() {
        isHighlighted = false
        resetHighlightedCornerViews(cornerViews: [topLeftCornerView, topRightCornerView, bottomLeftCornerView, bottomRightCornerView])
    }
    
    private func resetHighlightedCornerViews(cornerViews: [EditScanCornerView]) {
        cornerViews.forEach { (cornerView) in
            resetHightlightedCornerView(cornerView: cornerView)
        }
    }
    
    private func resetHightlightedCornerView(cornerView: EditScanCornerView) {
        cornerView.reset()
        let origin = CGPoint(x: cornerView.frame.origin.x + (cornerView.frame.size.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y + (cornerView.frame.size.height - cornerViewSize.width) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: cornerViewSize)
        cornerView.setNeedsDisplay()
    }
    
    // MARK: Validation
    
    /// Ensures that the given point is valid - meaning that it is within the bounds of the passed in `UIView`.
    ///
    /// - Parameters:
    ///   - point: The point that needs to be validated.
    ///   - cornerViewSize: The size of the corner view representing the given point.
    ///   - view: The view which should include the point.
    /// - Returns: A new point which is within the passed in view.
    private func validPoint(_ point: CGPoint, forCornerViewOfSize cornerViewSize: CGSize, inView view: UIView) -> CGPoint {
        var validPoint = point
        
        if point.x > view.bounds.width {
            validPoint.x = view.bounds.width
        } else if point.x < 0.0 {
            validPoint.x = 0.0
        }
        
        if point.y > view.bounds.height {
            validPoint.y = view.bounds.height
        } else if point.y < 0.0 {
            validPoint.y = 0.0
        }
        
        return validPoint
    }
    
    // MARK: - Convenience
    
    private func cornerViews(hidden: Bool) {
        topLeftCornerView.isHidden = hidden
        topRightCornerView.isHidden = hidden
        bottomRightCornerView.isHidden = hidden
        bottomLeftCornerView.isHidden = hidden
    }
    
    private func update(_ quad: Quadrilateral, withPosition position: CGPoint, forCorner corner: CornerPosition) -> Quadrilateral {
        var quad = quad
        
        switch corner {
        case .topLeft:
            quad.topLeft = position
        case .topRight:
            quad.topRight = position
        case .bottomRight:
            quad.bottomRight = position
        case .bottomLeft:
            quad.bottomLeft = position
        }
        
        return quad
    }
    
    func cornerViewForCornerPosition(position: CornerPosition) -> EditScanCornerView {
        switch position {
        case .topLeft:
            return topLeftCornerView
        case .topRight:
            return topRightCornerView
        case .bottomLeft:
            return bottomLeftCornerView
        case .bottomRight:
            return bottomRightCornerView
        }
    }
}
