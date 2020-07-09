//
//  Quadrilateral.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import UIKit

struct Quadrilateral {
    
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint
    
    var cgRect: CGRect {
        return CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x, height: bottomRight.y)
    }
    
    static var zero: Quadrilateral {
        return Quadrilateral(topLeft: .zero, topRight: .zero, bottomRight: .zero, bottomLeft: .zero)
    }
    
    var description:  String {
        return "topLeft: \(topLeft), topRight: \(topRight), bottomRight: \(bottomRight), bottomLeft: \(bottomLeft)"
    }
    
    var path: UIBezierPath {
        let path =  UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.close()
        return path
    }
    
    var cornerLayer: CAShapeLayer {
        let layer = CAShapeLayer()
        
        let maskPath = CGMutablePath()
        let boundX = topLeft.x + 1
        let boundY = topLeft.y + 1
        let boundWidth = bottomRight.x - 1
        let boundHeight = bottomRight.y - 1
        
        let cornerLength: CGFloat = 24
        
        //top left corner
        maskPath.move(to: CGPoint(x: boundX, y: boundY))
        maskPath.addLine(to: CGPoint(x: boundX + cornerLength, y:  boundY))
        maskPath.addLine(to: CGPoint(x: boundX + cornerLength, y: boundY + 3))
        maskPath.addLine(to: CGPoint(x: boundX + 3, y: boundY + 3))
        maskPath.addLine(to: CGPoint(x: boundX + 3, y: boundY + cornerLength))
        maskPath.addLine(to: CGPoint(x: boundX, y: boundY + cornerLength))
        maskPath.addLine(to: CGPoint(x: boundX, y: boundY))
        maskPath.closeSubpath()
        
        //top right corner
        maskPath.move(to: CGPoint(x: boundWidth - cornerLength, y: boundY))
        maskPath.addLine(to: CGPoint(x: boundWidth, y: boundY))
        maskPath.addLine(to: CGPoint(x: boundWidth, y: boundY + cornerLength))
        maskPath.addLine(to: CGPoint(x: boundWidth - 3, y: boundY + cornerLength))
        maskPath.addLine(to: CGPoint(x: boundWidth - 3, y: boundY + 3))
        maskPath.addLine(to: CGPoint(x: boundWidth - cornerLength, y: boundY + 3))
        maskPath.addLine(to: CGPoint(x:boundWidth - cornerLength, y: boundY))
        maskPath.closeSubpath()
        
        //bottom left corner
        maskPath.move(to: CGPoint(x: boundX, y: boundHeight - cornerLength))
        maskPath.addLine(to: CGPoint(x: boundX + 3, y: boundHeight - cornerLength))
        maskPath.addLine(to: CGPoint(x: boundX + 3, y: boundHeight - 3))
        maskPath.addLine(to: CGPoint(x: boundX + cornerLength, y: boundHeight - 3))
        maskPath.addLine(to: CGPoint(x: boundX + cornerLength, y: boundHeight))
        maskPath.addLine(to: CGPoint(x: boundX, y: boundHeight))
        maskPath.addLine(to: CGPoint(x: boundX, y: boundHeight - cornerLength))
        maskPath.closeSubpath()
        
        //bottom right corner
        maskPath.move(to: CGPoint(x: boundWidth - cornerLength, y: boundHeight))
        maskPath.addLine(to: CGPoint(x: boundWidth, y: boundHeight))
        maskPath.addLine(to: CGPoint(x: boundWidth, y: boundHeight - cornerLength))
        maskPath.addLine(to: CGPoint(x: boundWidth - 3, y: boundHeight - cornerLength))
        maskPath.addLine(to: CGPoint(x: boundWidth - 3, y: boundHeight - 3))
        maskPath.addLine(to: CGPoint(x: boundWidth - cornerLength, y: boundHeight - 3))
        maskPath.addLine(to: CGPoint(x: boundWidth - cornerLength, y: boundHeight))
        maskPath.closeSubpath()
        
        layer.path = maskPath
        layer.fillColor = UIColor.white.cgColor
        
        
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.duration = 0.5
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 1.0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(opacityAnimation, forKey: "fade")
        
        return layer
    }
    
    var perimeter: Double {
        let perimeter = topLeft.distanceTo(point: topRight) + topRight.distanceTo(point: bottomRight) + bottomRight.distanceTo(point: bottomLeft) + bottomLeft.distanceTo(point: topLeft)
        return Double(perimeter)
    }
    
    init(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }
    
    init(rect: CGRect) {
        self.topLeft = CGPoint(x: rect.minX, y: rect.minY)
        self.topRight = CGPoint(x: rect.maxX, y: rect.minY)
        self.bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        self.bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
    }
    
}

extension Quadrilateral {
    
    /// Checks whether the quadrilateral is withing a given distance of another quadrilateral.
    ///
    /// - Parameters:
    ///   - distance: The distance (threshold) to use for the condition to be met.
    ///   - rectangleFeature: The other rectangle to compare this instance with.
    /// - Returns: True if the given rectangle is within the given distance of this rectangle instance.
    func isWithin(_ distance: CGFloat, ofRectangleFeature rectangleFeature: Quadrilateral) -> Bool {
        
        let topLeftRect = topLeft.surroundingSquare(withSize: distance)
        if !topLeftRect.contains(rectangleFeature.topLeft) {
            return false
        }
        
        let topRightRect = topRight.surroundingSquare(withSize: distance)
        if !topRightRect.contains(rectangleFeature.topRight) {
            return false
        }
        
        let bottomRightRect = bottomRight.surroundingSquare(withSize: distance)
        if !bottomRightRect.contains(rectangleFeature.bottomRight) {
            return false
        }
        
        let bottomLeftRect = bottomLeft.surroundingSquare(withSize: distance)
        if !bottomLeftRect.contains(rectangleFeature.bottomLeft) {
            return false
        }
        
        return true
    }
    
    /// Reorganizes the current quadrilateal, making sure that the points are at their appropriate positions. For example, it ensures that the top left point is actually the top and left point point of the quadrilateral.
    mutating func reorganize() {
        let points = [topLeft, topRight, bottomRight, bottomLeft]
        let ySortedPoints = sortPointsByYValue(points)
        
        guard ySortedPoints.count == 4 else {
            return
        }
        
        let topMostPoints = Array(ySortedPoints[0..<2])
        let bottomMostPoints = Array(ySortedPoints[2..<4])
        let xSortedTopMostPoints = sortPointsByXValue(topMostPoints)
        let xSortedBottomMostPoints = sortPointsByXValue(bottomMostPoints)
        
        guard xSortedTopMostPoints.count > 1,
            xSortedBottomMostPoints.count > 1 else {
                return
        }
        
        topLeft = xSortedTopMostPoints[0]
        topRight = xSortedTopMostPoints[1]
        bottomRight = xSortedBottomMostPoints[1]
        bottomLeft = xSortedBottomMostPoints[0]
    }
    
    /// Scales the quadrilateral based on the ratio of two given sizes, and optionaly applies a rotation.
    ///
    /// - Parameters:
    ///   - fromSize: The size the quadrilateral is currently related to.
    ///   - toSize: The size to scale the quadrilateral to.
    ///   - rotationAngle: The optional rotation to apply.
    /// - Returns: The newly scaled and potentially rotated quadrilateral.
    func scale(_ fromSize: CGSize, _ toSize: CGSize, withRotationAngle rotationAngle: CGFloat = 0.0) -> Quadrilateral {
        var invertedfromSize = fromSize
        let rotated = rotationAngle != 0.0
        
        if rotated && rotationAngle != CGFloat.pi {
            invertedfromSize = CGSize(width: fromSize.height, height: fromSize.width)
        }
        
        var transformedQuad = self
        let invertedFromSizeWidth = invertedfromSize.width == 0 ? .leastNormalMagnitude : invertedfromSize.width
        
        let scale = toSize.width / invertedFromSizeWidth
        let scaledTransform = CGAffineTransform(scaleX: scale, y: scale)
        transformedQuad = transformedQuad.applying(scaledTransform)
        
        if rotated {
            let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
            
            let fromImageBounds = CGRect(origin: .zero, size: fromSize).applying(scaledTransform).applying(rotationTransform)
            
            let toImageBounds = CGRect(origin: .zero, size: toSize)
            let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: fromImageBounds, toCenterOfRect: toImageBounds)
            
            transformedQuad = transformedQuad.applyingTransforms([rotationTransform, translationTransform])
        }
        
        return transformedQuad
    }
    
    
    // Convenience functions
    
    /// Sorts the given `CGPoints` based on their y value.
    /// - Parameters:
    ///   - points: The poinmts to sort.
    /// - Returns: The points sorted based on their y value.
    private func sortPointsByYValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.y < point2.y
        }
    }
    
    /// Sorts the given `CGPoints` based on their x value.
    /// - Parameters:
    ///   - points: The points to sort.
    /// - Returns: The points sorted based on their x value.
    private func sortPointsByXValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.x < point2.x
        }
    }
    
    
    /// Converts the current to the cartesian coordinate system (where 0 on the y axis is at the bottom).
    ///
    /// - Parameters:
    ///   - height: The height of the rect containing the quadrilateral.
    /// - Returns: The same quadrilateral in the cartesian corrdinate system.
    func toCartesian(withHeight height: CGFloat) -> Quadrilateral {
        let topLeft = self.topLeft.cartesian(withHeight: height)
        let topRight = self.topRight.cartesian(withHeight: height)
        let bottomRight = self.bottomRight.cartesian(withHeight: height)
        let bottomLeft = self.bottomLeft.cartesian(withHeight: height)
        
        return Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
    
    func toCartesian(withWidth width: CGFloat) -> Quadrilateral {
        let topLeft = self.topLeft.cartesian(withWidth: width)
        let topRight = self.topRight.cartesian(withWidth: width)
        let bottomRight = self.bottomRight.cartesian(withWidth: width)
        let bottomLeft = self.bottomLeft.cartesian(withWidth: width)
        
        return Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
}
