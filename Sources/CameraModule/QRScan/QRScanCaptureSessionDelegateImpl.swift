//
//  QRScanCaptureSessionDelegateImpl.swift
//  CameraX
//
//  Created by Prashant Shrestha on 23/11/2020.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

class QRScanCaptureSessionDelegateImpl: NSObject, CaptureSessionDelegate {
    
    private weak var qrScanViewController: QRScanViewController!
    
    private var isDetecting: Bool = false
    /// The number of times no rectangles have been found in a row.
    private var numberOfRectangle: Int = 0
    /// The minimum number of time required by `numberOfRectangle` to validate that no rectangles have been found.
    private let numberOfRectangleThreshold = 3
    private var rectangleFunnel = RectangleFeaturesFunnel()
    private var displayedRectangleResult: RectangleDetectorResult?
    
    
    
    init(qrScanViewController: QRScanViewController) {
        self.qrScanViewController = qrScanViewController
        rectangleFunnel.autoScanThreshold = 10
    }
    
    func didStartCapturingPicture(from captureSessionManager: CaptureSessionManager) {
        captureSessionManager.stop()
        qrScanViewController.shutterButton.isUserInteractionEnabled = false
        
        
        isDetecting = false
        rectangleFunnel.currentAutoScanPassCount = 0
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didOutput pixelBuffer: CVImageBuffer, imageSize: CGSize) {
        isDetecting = true
        self.processPixelBuffer(captureSessionManager: captureSessionManager, pixelBuffer: pixelBuffer, imageSize: imageSize)
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage) {
        
        var angle: CGFloat = 0.0
        
        switch picture.imageOrientation {
        case .right:
            angle = CGFloat.pi / 2
        case .up:
            angle = CGFloat.pi
        default:
            break
        }
        
        var quad: Quadrilateral?
        if let displayedRectangleResult = self.displayedRectangleResult {
            quad = self.displayRectangleResult(rectangleResult: displayedRectangleResult)
            quad = quad?.scale(displayedRectangleResult.imageSize, picture.size, withRotationAngle: angle)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.qrScanViewController.processImageCropping(captureSessionManager, image: picture, quad: quad)
        }
        
        captureSessionManager.start()
        qrScanViewController.shutterButton.isUserInteractionEnabled = true
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        
        captureSessionManager.start()
        qrScanViewController.shutterButton.isUserInteractionEnabled = true
    }
}


// MARK: - Auto Detect Video Processing
extension QRScanCaptureSessionDelegateImpl {
    func processPixelBuffer(captureSessionManager: CaptureSessionManager, pixelBuffer: CVImageBuffer, imageSize: CGSize) {
        guard isDetecting == true else {
            self.qrScanViewController.processForQuads(quad: nil, size: imageSize)
            return
        }
        
        CIQRDetector.rectangle(forPixelBuffer: pixelBuffer) { quad in
            self.processRectangle(captureSessionManager: captureSessionManager, rectangle: quad, imageSize: imageSize)
        }
    }
    
    func processRectangle(captureSessionManager: CaptureSessionManager, rectangle: Quadrilateral?, imageSize: CGSize) {
        if let rectangle = rectangle {
            self.numberOfRectangle = 0
            self.rectangleFunnel.add(rectangle, currentlyDisplayedRectangle: self.displayedRectangleResult?.rectangle) { [weak self] (result, rectangle) in
                
                guard let strongSelf = self else { return }
                
                let shouldAutoCapture = result == .showAndAutoScan
                strongSelf.displayRectangleResult(rectangleResult: RectangleDetectorResult(rectangle: rectangle, imageSize: imageSize))
                
                if shouldAutoCapture, !CaptureSession.current.isEditing {
                    captureSessionManager.capturePhoto()
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.numberOfRectangle += 1
                
                if strongSelf.numberOfRectangle > strongSelf.numberOfRectangleThreshold {
                    // Reset the currentAutoScanPassCount, so the threshold is restarted the next time a rectangle is found
                    strongSelf.rectangleFunnel.currentAutoScanPassCount = 0
                    
                    // Remove the currently displayed rectangle as no rectangles are being found anymore
                    strongSelf.displayedRectangleResult = nil
                    strongSelf.qrScanViewController.processForQuads(quad: nil, size: imageSize)
                }
            }
            return
            
        }
    }
    
    @discardableResult private func displayRectangleResult(rectangleResult: RectangleDetectorResult) -> Quadrilateral {
        displayedRectangleResult = rectangleResult
        
        let quad = rectangleResult.rectangle.toCartesian(withHeight: rectangleResult.imageSize.height)
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.qrScanViewController.processForQuads(quad: quad, size: rectangleResult.imageSize)
        }
        
        return quad
    }
    
}


// MARK: - Quad Processing
fileprivate extension QRScanViewController {
    func processForQuads(quad: Quadrilateral?, size: CGSize) {
        if let quad = quad {
            let portraitImageSize = CGSize(width: size.height, height: size.width)

            let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
            let scaledImageSize = size.applying(scaleTransform)

            let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)

            let imageBounds = CGRect(origin: .zero, size: scaledImageSize)
            let imageBoundsRotated = imageBounds.applying(rotationTransform)

            let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBoundsRotated, toCenterOfRect: quadView.bounds)

            let transforms = [scaleTransform, rotationTransform, translationTransform]

            let transformedQuad = quad.applyingTransforms(transforms)
            quadView.drawQuadrilateral(quad: transformedQuad, animated: true)
        } else if let defaultQuad = defaultQuad {
            quadView.drawQuadrilateral(quad: defaultQuad, animated: true)
        } else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            reset()
        }
    }
}

// MARK: - Image Capture Proccessing
fileprivate extension QRScanViewController {
    
    func processImageCropping(_ captureSessionManager: CaptureSessionManager, image: UIImage, quad: Quadrilateral?) {
        guard let quad = quad,
            let ciImage = CIImage(image: image) else {
            let error = CameraError.ciImageCreation
            captureSessionDelegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
        
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        
        let imageSize = image.size
        let iFrame = AVMakeRect(aspectRatio: imageSize, insideRect: quadView.bounds)
        let imageFrame = CGRect(origin: quadView.frame.origin, size: CGSize(width: iFrame.width, height: iFrame.height))
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyingTransforms(transforms)
        let scaledQuad = transformedQuad.scale(quadView.bounds.size, image.size)
        
        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
            ])
        
        let croppedImage = UIImage.from(ciImage: filteredImage)
        // Enhanced Image
        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        let enhancedScan = enhancedImage.flatMap { ImageScan(image: $0) }
        
        let result = ImageScanResult(originalScan: ImageScan(image: image),
                                     croppedScan: ImageScan(image: croppedImage),
                                     enhancedScan: enhancedScan)
        
        let qrFeatures = CIQRDetector.qrFeatures(forImage: orientedImage)
        let biggestQuad = qrFeatures?.map(Quadrilateral.init).biggest()
        let filteredQRFeatures = qrFeatures?.filter({ (qrFeature) -> Bool in
            let qrQuad = Quadrilateral(qrFeature: qrFeature)
            return biggestQuad?.cgRect.contains(qrQuad.cgRect) ?? false
        })
        if let messageString = filteredQRFeatures?.first?.messageString {
            self.results(result, messageString)
        }
    }
}
