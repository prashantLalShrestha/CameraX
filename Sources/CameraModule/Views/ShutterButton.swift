//
//  ShutterButton.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit

public final class ShutterButton: UIControl {
    
    private let outerRingLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()
    
    private let outerRingRatio: CGFloat = 0.80
    private let innerRingRatio: CGFloat = 0.75
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    public override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                animateInnerCircleLayer(forHighlightedState: isHighlighted)
            }
        }
    }
    
    public var outerRingColor: UIColor = UIColor.white {
        didSet {
            if outerRingColor != oldValue {
                outerRingLayer.fillColor = outerRingColor.cgColor
            }
        }
    }
    
    public var innerRingColor: UIColor = UIColor.white {
        didSet {
            if innerRingColor != oldValue {
                innerCircleLayer.fillColor = innerRingColor.cgColor
            }
        }
    }
    
    // MARK: - Life Cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(outerRingLayer)
        layer.addSublayer(innerCircleLayer)
        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button
        impactFeedbackGenerator.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        outerRingLayer.frame = rect
        outerRingLayer.path = pathForOuterRing(in: rect).cgPath
        outerRingLayer.fillColor = outerRingColor.cgColor
        outerRingLayer.rasterizationScale = UIScreen.main.scale
        outerRingLayer.shouldRasterize = true
        
        innerCircleLayer.frame = rect
        innerCircleLayer.path = pathForInnerCircle(in: rect).cgPath
        innerCircleLayer.fillColor = innerRingColor.cgColor
        innerCircleLayer.rasterizationScale = UIScreen.main.scale
        innerCircleLayer.shouldRasterize = true
    }
    
    // MARK: - Animation
    private func animateInnerCircleLayer(forHighlightedState isHighlighted: Bool) {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        var values = [
            CATransform3DMakeScale(1.0, 1.0, 1.0),
            CATransform3DMakeScale(0.9, 0.9, 0.9),
            CATransform3DMakeScale(0.93, 0.93, 0.93),
            CATransform3DMakeScale(0.9, 0.9, 0.9)
        ]
        
        if isHighlighted == false {
            values = [
                CATransform3DMakeScale(0.9, 0.9, 0.9),
                CATransform3DMakeScale(1.0, 1.0, 1.0)
            ]
        }
        animation.values = values
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.duration = isHighlighted ? 0.35 : 0.10
        
        innerCircleLayer.add(animation, forKey: "transform")
        impactFeedbackGenerator.impactOccurred()
    }
    
    // MARK: - Paths
    private func pathForOuterRing(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(ovalIn: rect)

        let innerRect = rect.scaleAndCenter(withRatio: outerRingRatio)
        let innerPath = UIBezierPath(ovalIn: innerRect).reversing()
        
        path.append(innerPath)
        
        return path
    }
    
    private func pathForInnerCircle(in rect: CGRect) -> UIBezierPath {
        let rect = rect.scaleAndCenter(withRatio: innerRingRatio)
        let path = UIBezierPath(ovalIn: rect)
        
        return path
    }
    
}
