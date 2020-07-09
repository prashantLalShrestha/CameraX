//
//  FaceScanCaptureSessionDelegateImpl.swift
//  Saguna
//
//  Created by Prashant Shrestha on 7/3/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

class FaceScanCaptureSessionDelegateImpl: NSObject, CaptureSessionDelegate {
    
    private weak var documentScanViewController: FaceScanViewController!
    
    private var isDetecting: Bool = false
    
    private var rectangleFunnel = RectangleFeaturesFunnel()
    private var displayedRectangleResult: RectangleDetectorResult?
    
    init(documentScanViewController: FaceScanViewController) {
        self.documentScanViewController = documentScanViewController
    }
    
    
    func didStartCaptureSession(in captureSessionManager: CaptureSessionManager) {
        
    }
    
    func didStopCaptureSession(in captureSessionManager: CaptureSessionManager) {
        
    }
    
    func didStartCapturingPicture(from captureSessionManager: CaptureSessionManager) {
        captureSessionManager.stop()
        documentScanViewController.shutterButton.isUserInteractionEnabled = false
        
        isDetecting = false
        rectangleFunnel.currentAutoScanPassCount = 0
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didOutput pixelBuffer: CVImageBuffer, imageSize: CGSize) {
        
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
            guard let strongSelf = self else {
                return
            }
            strongSelf.documentScanViewController.processImageCropping(captureSessionManager, image: picture, quad: quad)
        }
        
        captureSessionManager.start()
        documentScanViewController.shutterButton.isUserInteractionEnabled = true
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        
        captureSessionManager.start()
        documentScanViewController.shutterButton.isUserInteractionEnabled = true
    }
    
    
}


// MARK: - Auto Detect Video Processing
extension FaceScanCaptureSessionDelegateImpl {
    func processPixelBuffer(captureSessionManager: CaptureSessionManager, pixelBuffer: CVImageBuffer, imageSize: CGSize) {
        guard isDetecting == true else {
            self.documentScanViewController.processForQuads(quad: nil, size: imageSize)
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
            strongSelf.documentScanViewController.processForQuads(quad: quad, size: rectangleResult.imageSize)
        }
        
        return quad
    }
    
}


// MARK: - Quad Processing
fileprivate extension FaceScanViewController {
    func processForQuads(quad: Quadrilateral?, size: CGSize) {
        guard let quad = quad else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            quadView.removeQuadrilateral()
            return
        }
        
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
    }
}

// MARK: - Image Capture Proccessing
fileprivate extension FaceScanViewController {
    
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
//        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        
        self.image?(croppedImage)
    }
}
