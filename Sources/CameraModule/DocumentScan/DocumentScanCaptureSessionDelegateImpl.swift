//
//  DocumentScanCaptureSessionDelegateImpl.swift
//  Saguna
//
//  Created by Prashant Shrestha on 7/3/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

class DocumentScanCaptureSessionDelegateImpl: NSObject, CaptureSessionDelegate {
    
    private weak var documentScanViewController: DocumentScanViewController!
    
    private var isDetecting: Bool = false
    /// The number of times no rectangles have been found in a row.
    private var numberOfRectangle: Int = 0
    /// The minimum number of time required by `numberOfRectangle` to validate that no rectangles have been found.
    private let numberOfRectangleThreshold = 3
    private var rectangleFunnel = RectangleFeaturesFunnel()
    private var displayedRectangleResult: RectangleDetectorResult?
    
    init(documentScanViewController: DocumentScanViewController) {
        self.documentScanViewController = documentScanViewController
    }
    
    func didStartCapturingPicture(from captureSessionManager: CaptureSessionManager) {
        captureSessionManager.stop()
        documentScanViewController.shutterButton.isUserInteractionEnabled = false
        
        
        isDetecting = false
        rectangleFunnel.currentAutoScanPassCount = 0
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didOutput pixelBuffer: CVImageBuffer, imageSize: CGSize) {
        
        switch documentScanViewController.currentScanType() {
        case .auto:
            isDetecting = true
            self.processPixelBuffer(captureSessionManager: captureSessionManager, pixelBuffer: pixelBuffer, imageSize: imageSize)
        default:
            isDetecting = false
            numberOfRectangle = 0
            rectangleFunnel = RectangleFeaturesFunnel()
            self.displayedRectangleResult = nil
            
            return
        }
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage) {
        
        switch documentScanViewController.currentScanType() {
        case .auto:
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
                if self.documentScanViewController.navigationController != nil {
                    self.documentScanViewController.pushToEdit(image: picture, quad: quad)
                } else {
                    self.documentScanViewController.processImageCroppingForAutoScanType(captureSessionManager, image: picture, quad: quad)
                }
            }
        case .manual:
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.documentScanViewController.processImageCroppingForManualScanType(captureSessionManager, image: picture, quad: strongSelf.documentScanViewController.manualQuadView.quad!)
            }
        }
        
        if !documentScanViewController.isBeingDismissed {
            captureSessionManager.start()
            documentScanViewController.shutterButton.isUserInteractionEnabled = true
        }
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        
        if !documentScanViewController.isBeingDismissed {
            captureSessionManager.start()
            documentScanViewController.shutterButton.isUserInteractionEnabled = true
        }
    }
    
    
}


// MARK: - Auto Detect Video Processing
extension DocumentScanCaptureSessionDelegateImpl {
    func processPixelBuffer(captureSessionManager: CaptureSessionManager, pixelBuffer: CVImageBuffer, imageSize: CGSize) {
        guard isDetecting == true else {
            self.documentScanViewController.processForQuads(quad: nil, size: imageSize)
            return
        }
        
        VisionRectangleDetector.rectangle(forPixelBuffer: pixelBuffer) { quad in
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
                    strongSelf.documentScanViewController.processForQuads(quad: nil, size: imageSize)
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
            strongSelf.documentScanViewController.processForQuads(quad: quad, size: rectangleResult.imageSize)
        }
        
        return quad
    }
    
}


// MARK: - Quad Processing
fileprivate extension DocumentScanViewController {
    func processForQuads(quad: Quadrilateral?, size: CGSize) {
        guard let quad = quad else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            autoQuadView.removeQuadrilateral()
            return
        }
        
        let portraitImageSize = CGSize(width: size.height, height: size.width)
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: autoQuadView.bounds.size)
        let scaledImageSize = size.applying(scaleTransform)
        
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)

        let imageBounds = CGRect(origin: .zero, size: scaledImageSize)
        let imageBoundsRotated = imageBounds.applying(rotationTransform)

        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBoundsRotated, toCenterOfRect: autoQuadView.bounds)
        
        let transforms = [scaleTransform, rotationTransform, translationTransform]
        
        let transformedQuad = quad.applyingTransforms(transforms)
        autoQuadView.drawQuadrilateral(quad: transformedQuad, animated: true)
    }
}

// MARK: - Image Capture Proccessing
fileprivate extension DocumentScanViewController {
    func processImageCroppingForManualScanType(_ captureSessionManager: CaptureSessionManager, image: UIImage, quad: Quadrilateral) {
        guard let ciImage = CIImage(image: image) else {
            let error = CameraError.ciImageCreation
            captureSessionDelegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
        
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        
        let imageSize = image.size
        let iFrame = AVMakeRect(aspectRatio: imageSize, insideRect: contentView.bounds)
        let imageFrame = iFrame.scaleAndCenter(withRatio: contentView.bounds.height / iFrame.size.height)
        
        let scaledQuad = quad.scale(imageFrame.size, imageSize)
        
        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: imageSize.height)
        cartesianScaledQuad.reorganize()
        var cartesianScaledQuadX = cartesianScaledQuad.toCartesian(withWidth: imageSize.width - imageFrame.size.width / 1.5)
        cartesianScaledQuadX.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuadX.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuadX.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuadX.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuadX.topRight)
            ])
        
        let croppedImage = UIImage.from(ciImage: filteredImage)
        // Enhanced Image
        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        let enhancedScan = enhancedImage.flatMap { ImageScan(image: $0) }
        
        let result = ImageScanResult(originalScan: ImageScan(image: image),
                                     croppedScan: ImageScan(image: croppedImage),
                                     enhancedScan: enhancedScan)
        
        self.results(result)
    }
    
    func processImageCroppingForAutoScanType(_ captureSessionManager: CaptureSessionManager, image: UIImage, quad: Quadrilateral?) {
        guard let quad = quad,
            let ciImage = CIImage(image: image) else {
            let error = CameraError.ciImageCreation
            captureSessionDelegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
        
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        
        let imageSize = image.size
        let iFrame = AVMakeRect(aspectRatio: imageSize, insideRect: autoQuadView.bounds)
        let imageFrame = CGRect(origin: autoQuadView.frame.origin, size: CGSize(width: iFrame.width, height: iFrame.height))
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyingTransforms(transforms)
        let scaledQuad = transformedQuad.scale(autoQuadView.bounds.size, image.size)
        
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
        
        self.results(result)
    }
    
    func pushToEdit(image: UIImage, quad: Quadrilateral?) {
        let editClosures = PictureEditViewController.PictureEditViewClosure(cancelAction: {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }, failedWithError: { error in
            self.captureSessionDelegate?.captureSessionManager(self.captureSessionManager!, didFailWithError: error)
        }, nextAction: { results in
            self.results(results)
        })
        let editVC = PictureEditViewController(image: image, quad: quad, closures: editClosures)
        navigationController?.pushViewController(editVC, animated: false)
    }
}
