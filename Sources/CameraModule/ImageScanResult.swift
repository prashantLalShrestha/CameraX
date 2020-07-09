//
//  ImageScanResult.swift
//  Saguna
//
//  Created by Prashant Shrestha on 7/9/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit

/// Data structure containing information about a scanning session.
/// Includes the original scan, cropped scan, detected rectangle, and whether the user selected the enhanced scan. May also include an enhanced scan if no errors were encountered.
public struct ImageScanResult {
    
    /// The original scan taken by the user, prior to the cropping applied by WeScan.
    public var originalScan: ImageScan
    
    /// The deskewed and cropped scan using the detected rectangle, without any filters.
    public var croppedScan: ImageScan
    
    /// The enhanced scan, passed through an Adaptive Thresholding function. This image will always be grayscale and may not always be available.
    public var enhancedScan: ImageScan?
    
    init(originalScan: ImageScan, croppedScan: ImageScan, enhancedScan: ImageScan?) {
        
        self.originalScan = originalScan
        self.croppedScan = croppedScan
        self.enhancedScan = enhancedScan
    }
}

/// Data structure containing information about a scan, including both the image and an optional PDF.
public struct ImageScan {
    public enum ImageScanError: Error {
        case failedToGeneratePDF
    }
    
    public var image: UIImage
    
    public func generatePDFData(completion: @escaping (Result<Data, ImageScanError>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let pdfData = self.image.pdfData() {
                completion(.success(pdfData))
            } else {
                completion(.failure(.failedToGeneratePDF))
            }
        }
        
    }
    
    mutating func rotate(by rotationAngle: Measurement<UnitAngle>) {
        guard rotationAngle.value != 0, rotationAngle.value != 360 else { return }
        image = image.rotated(by: rotationAngle) ?? image
    }
}
