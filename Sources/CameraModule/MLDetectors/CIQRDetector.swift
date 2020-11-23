//
//  CIQRDetector.swift
//  CameraX
//
//  Created by Prashant Shrestha on 23/11/2020.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import UIKit

/// Class used to detect rectangles from an image.
@available(iOS 11.0, *)
enum CIQRDetector {
    static let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode,
                                              context: CIContext(options: nil),
                                              options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    
    /// Detects rectangles from the given CVPixelBuffer/CVImageBuffer on iOS 10.
    ///
    /// - Parameters:
    ///   - pixelBuffer: The pixelBuffer to detect rectangles on.
    ///   - completion: The biggest rectangle on the CVPixelBuffer
    static func rectangle(forPixelBuffer pixelBuffer: CVPixelBuffer, completion: @escaping ((Quadrilateral?) -> Void)) {
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let biggestRectangle = rectangle(forImage: image)
        completion(biggestRectangle)
    }
    
    
    /// Detects rectangles from the given image on iOS 10.
    ///
    /// - Parameters:
    ///   - image: The image to detect rectangles on.
    ///   - completion: The biggest rectangle on the CIImage
    static func rectangle(forImage image: CIImage, completion: @escaping ((Quadrilateral?) -> Void)) {
        let biggestRectangle = rectangle(forImage: image)
        completion(biggestRectangle)
    }
    
    /// Detects rectangles from the given image on iOS 10.
    ///
    /// - Parameters:
    ///   - image: The image to detect rectangles on.
    /// - Returns: The biggest detected rectangle on the image.
    static func rectangle(forImage image: CIImage) -> Quadrilateral? {
        guard let qrFeatures = qrFeatures(forImage: image) else {
            return nil
        }
        
        let quads = qrFeatures.map(Quadrilateral.init)
        
        return quads.biggest()
    }
    
    static func qrFeatures(forImage image: CIImage) -> [CIQRCodeFeature]? {
        guard let qrFeatures = qrDetector?.features(in: image) as? [CIQRCodeFeature] else {
            return nil
        }
        
        return qrFeatures.filter{ $0.messageString != nil && $0.messageString != "" }
    }
}
