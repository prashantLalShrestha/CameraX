//
//  UIImage+Shapes.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    static func closeImage() -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)).image { _ in
            //// Color Declarations
            let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 284.29, y: 256))
            bezierPath.addLine(to: CGPoint(x: 506.14, y: 34.14))
            bezierPath.addCurve(to: CGPoint(x: 506.14, y: 5.86), controlPoint1: CGPoint(x: 513.95, y: 26.33), controlPoint2: CGPoint(x: 513.95, y: 13.67))
            bezierPath.addCurve(to: CGPoint(x: 477.86, y: 5.86), controlPoint1: CGPoint(x: 498.33, y: -1.95), controlPoint2: CGPoint(x: 485.67, y: -1.95))
            bezierPath.addLine(to: CGPoint(x: 256, y: 227.72))
            bezierPath.addLine(to: CGPoint(x: 34.14, y: 5.86))
            bezierPath.addCurve(to: CGPoint(x: 5.86, y: 5.86), controlPoint1: CGPoint(x: 26.33, y: -1.95), controlPoint2: CGPoint(x: 13.67, y: -1.95))
            bezierPath.addCurve(to: CGPoint(x: 5.86, y: 34.14), controlPoint1: CGPoint(x: -1.95, y: 13.67), controlPoint2: CGPoint(x: -1.95, y: 26.33))
            bezierPath.addLine(to: CGPoint(x: 227.72, y: 256))
            bezierPath.addLine(to: CGPoint(x: 5.86, y: 477.86))
            bezierPath.addCurve(to: CGPoint(x: 5.86, y: 506.14), controlPoint1: CGPoint(x: -1.95, y: 485.67), controlPoint2: CGPoint(x: -1.95, y: 498.33))
            bezierPath.addCurve(to: CGPoint(x: 20, y: 512), controlPoint1: CGPoint(x: 9.76, y: 510.05), controlPoint2: CGPoint(x: 14.88, y: 512))
            bezierPath.addCurve(to: CGPoint(x: 34.14, y: 506.14), controlPoint1: CGPoint(x: 25.12, y: 512), controlPoint2: CGPoint(x: 30.24, y: 510.05))
            bezierPath.addLine(to: CGPoint(x: 256, y: 284.29))
            bezierPath.addLine(to: CGPoint(x: 477.86, y: 506.14))
            bezierPath.addCurve(to: CGPoint(x: 492, y: 512), controlPoint1: CGPoint(x: 481.76, y: 510.05), controlPoint2: CGPoint(x: 486.88, y: 512))
            bezierPath.addCurve(to: CGPoint(x: 506.14, y: 506.14), controlPoint1: CGPoint(x: 497.12, y: 512), controlPoint2: CGPoint(x: 502.24, y: 510.05))
            bezierPath.addCurve(to: CGPoint(x: 506.14, y: 477.86), controlPoint1: CGPoint(x: 513.95, y: 498.33), controlPoint2: CGPoint(x: 513.95, y: 485.67))
            bezierPath.addLine(to: CGPoint(x: 284.29, y: 256))
            bezierPath.close()
            fillColor.setFill()
            bezierPath.fill()
        }
    }
    
    static func backArrowImage() -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)).image { _ in
            //// Color Declarations
            let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

            let bezier2Path = UIBezierPath()
            bezier2Path.move(to: CGPoint(x: 353.64, y: 477.87))
            bezier2Path.addLine(to: CGPoint(x: 146.34, y: 270.14))
            bezier2Path.addCurve(to: CGPoint(x: 146.36, y: 241.84), controlPoint1: CGPoint(x: 138.55, y: 262.34), controlPoint2: CGPoint(x: 138.55, y: 249.66))
            bezier2Path.addLine(to: CGPoint(x: 353.64, y: 34.13))
            bezier2Path.addCurve(to: CGPoint(x: 353.61, y: 5.84), controlPoint1: CGPoint(x: 361.45, y: 26.31), controlPoint2: CGPoint(x: 361.43, y: 13.65))
            bezier2Path.addCurve(to: CGPoint(x: 325.33, y: 5.87), controlPoint1: CGPoint(x: 345.79, y: -1.96), controlPoint2: CGPoint(x: 333.13, y: -1.95))
            bezier2Path.addLine(to: CGPoint(x: 118.06, y: 213.57))
            bezier2Path.addCurve(to: CGPoint(x: 118.05, y: 298.41), controlPoint1: CGPoint(x: 94.67, y: 236.97), controlPoint2: CGPoint(x: 94.67, y: 275.03))
            bezier2Path.addLine(to: CGPoint(x: 325.33, y: 506.13))
            bezier2Path.addCurve(to: CGPoint(x: 339.49, y: 512), controlPoint1: CGPoint(x: 329.24, y: 510.04), controlPoint2: CGPoint(x: 334.36, y: 512))
            bezier2Path.addCurve(to: CGPoint(x: 353.61, y: 506.16), controlPoint1: CGPoint(x: 344.6, y: 512), controlPoint2: CGPoint(x: 349.71, y: 510.05))
            bezier2Path.addCurve(to: CGPoint(x: 353.64, y: 477.87), controlPoint1: CGPoint(x: 361.43, y: 498.35), controlPoint2: CGPoint(x: 361.45, y: 485.69))
            bezier2Path.close()
            fillColor.setFill()
            bezier2Path.fill()
        }
    }
    
    static func flashUnavailableImage() -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: 318, height: 510)).image { _ in
            
            //// Color Declarations
            let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

            //// Bezier Drawing
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 316.62, y: 196.41))
            bezierPath.addLine(to: CGPoint(x: 316.58, y: 196.33))
            bezierPath.addCurve(to: CGPoint(x: 307.34, y: 191), controlPoint1: CGPoint(x: 314.68, y: 193.03), controlPoint2: CGPoint(x: 311.15, y: 191))
            bezierPath.addLine(to: CGPoint(x: 167.61, y: 191))
            bezierPath.addLine(to: CGPoint(x: 191.04, y: 12.01))
            bezierPath.addLine(to: CGPoint(x: 191.04, y: 12.01))
            bezierPath.addCurve(to: CGPoint(x: 181.49, y: 0.22), controlPoint1: CGPoint(x: 191.66, y: 6.11), controlPoint2: CGPoint(x: 187.38, y: 0.84))
            bezierPath.addCurve(to: CGPoint(x: 171.37, y: 5.04), controlPoint1: CGPoint(x: 177.48, y: -0.21), controlPoint2: CGPoint(x: 173.57, y: 1.66))
            bezierPath.addLine(to: CGPoint(x: 1.45, y: 302.75))
            bezierPath.addLine(to: CGPoint(x: 1.49, y: 302.68))
            bezierPath.addCurve(to: CGPoint(x: 4.88, y: 317.38), controlPoint1: CGPoint(x: -1.64, y: 307.68), controlPoint2: CGPoint(x: -0.12, y: 314.26))
            bezierPath.addCurve(to: CGPoint(x: 10.53, y: 319), controlPoint1: CGPoint(x: 6.57, y: 318.44), controlPoint2: CGPoint(x: 8.53, y: 319))
            bezierPath.addLine(to: CGPoint(x: 148.18, y: 319))
            bezierPath.addLine(to: CGPoint(x: 129.61, y: 498.26))
            bezierPath.addLine(to: CGPoint(x: 129.61, y: 498.33))
            bezierPath.addCurve(to: CGPoint(x: 139.56, y: 509.79), controlPoint1: CGPoint(x: 129.19, y: 504.25), controlPoint2: CGPoint(x: 133.65, y: 509.37))
            bezierPath.addCurve(to: CGPoint(x: 149.41, y: 504.77), controlPoint1: CGPoint(x: 143.52, y: 510.06), controlPoint2: CGPoint(x: 147.31, y: 508.13))
            bezierPath.addLine(to: CGPoint(x: 316.5, y: 207.15))
            bezierPath.addLine(to: CGPoint(x: 316.49, y: 207.16))
            bezierPath.addCurve(to: CGPoint(x: 316.67, y: 196.5), controlPoint1: CGPoint(x: 318.45, y: 203.89), controlPoint2: CGPoint(x: 318.52, y: 199.83))
            bezierPath.addLine(to: CGPoint(x: 316.62, y: 196.41))
            bezierPath.close()
            fillColor.setFill()
            bezierPath.fill()

        }
    }
    
    
    static func flashImage() -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: 120, height: 192)).image { _ in
            //// Color Declarations
            let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
            let strokeColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

            //// Group_352
            //// lightning Drawing
            let lightningPath = UIBezierPath()
            lightningPath.move(to: CGPoint(x: 119.04, y: 73.85))
            lightningPath.addLine(to: CGPoint(x: 119.02, y: 73.82))
            lightningPath.addCurve(to: CGPoint(x: 115.56, y: 71.82), controlPoint1: CGPoint(x: 118.31, y: 72.58), controlPoint2: CGPoint(x: 116.99, y: 71.82))
            lightningPath.addLine(to: CGPoint(x: 63.16, y: 71.82))
            lightningPath.addLine(to: CGPoint(x: 71.95, y: 4.7))
            lightningPath.addLine(to: CGPoint(x: 71.95, y: 4.7))
            lightningPath.addCurve(to: CGPoint(x: 68.37, y: 0.28), controlPoint1: CGPoint(x: 72.18, y: 2.49), controlPoint2: CGPoint(x: 70.58, y: 0.51))
            lightningPath.addCurve(to: CGPoint(x: 64.57, y: 2.09), controlPoint1: CGPoint(x: 66.86, y: 0.12), controlPoint2: CGPoint(x: 65.39, y: 0.82))
            lightningPath.addLine(to: CGPoint(x: 0.85, y: 113.72))
            lightningPath.addLine(to: CGPoint(x: 0.86, y: 113.7))
            lightningPath.addCurve(to: CGPoint(x: 2.13, y: 119.21), controlPoint1: CGPoint(x: -0.31, y: 115.57), controlPoint2: CGPoint(x: 0.26, y: 118.04))
            lightningPath.addCurve(to: CGPoint(x: 4.25, y: 119.82), controlPoint1: CGPoint(x: 2.77, y: 119.61), controlPoint2: CGPoint(x: 3.5, y: 119.82))
            lightningPath.addLine(to: CGPoint(x: 55.87, y: 119.82))
            lightningPath.addLine(to: CGPoint(x: 48.91, y: 187.05))
            lightningPath.addLine(to: CGPoint(x: 48.91, y: 187.07))
            lightningPath.addCurve(to: CGPoint(x: 52.64, y: 191.37), controlPoint1: CGPoint(x: 48.75, y: 189.29), controlPoint2: CGPoint(x: 50.43, y: 191.21))
            lightningPath.addCurve(to: CGPoint(x: 56.34, y: 189.48), controlPoint1: CGPoint(x: 54.13, y: 191.47), controlPoint2: CGPoint(x: 55.55, y: 190.75))
            lightningPath.addLine(to: CGPoint(x: 118.99, y: 77.88))
            lightningPath.addLine(to: CGPoint(x: 118.99, y: 77.88))
            lightningPath.addCurve(to: CGPoint(x: 119.06, y: 73.88), controlPoint1: CGPoint(x: 119.73, y: 76.66), controlPoint2: CGPoint(x: 119.75, y: 75.13))
            lightningPath.addLine(to: CGPoint(x: 119.04, y: 73.85))
            lightningPath.close()
            fillColor.setFill()
            lightningPath.fill()


            //// Line_16 Drawing
            let line_16Path = UIBezierPath()
            line_16Path.move(to: CGPoint(x: 0.76, y: 0.76))
            line_16Path.addLine(to: CGPoint(x: 119.76, y: 191.76))
            strokeColor.setStroke()
            line_16Path.lineWidth = 4
            line_16Path.miterLimit = 4
            line_16Path.lineCapStyle = .round
            line_16Path.stroke()
        }
    }
    
    func scaled(to newSize: CGSize = CGSize(width: 32, height: 32)) -> UIImage? {
        let type = self
        let imageAspectRatio = type.size.width / type.size.height
        let canvasAspectRatio = newSize.width / newSize.height

        var resizeFactor: CGFloat

        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = newSize.width / type.size.width
        } else {
            resizeFactor = newSize.height / type.size.height
        }

        let scaledSize = CGSize(width: type.size.width * resizeFactor, height: type.size.height * resizeFactor)
        let origin = CGPoint(x: (newSize.width - scaledSize.width) / 2.0, y: (newSize.height - scaledSize.height) / 2.0)

        UIGraphicsBeginImageContextWithOptions(newSize, false, type.scale)
        type.draw(in: CGRect(origin: origin, size: scaledSize))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? type
        UIGraphicsEndImageContext()

        return scaledImage
    }

      /// Draws a new cropped and scaled (zoomed in) image.
      ///
      /// - Parameters:
      ///   - point: The center of the new image.
      ///   - scaleFactor: Factor by which the image should be zoomed in.
      ///   - size: The size of the rect the image will be displayed in.
      /// - Returns: The scaled and cropped image.
      func scaledImage(atPoint point: CGPoint, scaleFactor: CGFloat, targetSize size: CGSize) -> UIImage? {
          guard let cgImage = self.cgImage else { return nil }
          
          let scaledSize = CGSize(width: size.width / scaleFactor, height: size.height / scaleFactor)
          let midX = point.x - scaledSize.width / 2.0
          let midY = point.y - scaledSize.height / 2.0
          let newRect = CGRect(x: midX, y: midY, width: scaledSize.width, height: scaledSize.height)
          
          guard let croppedImage = cgImage.cropping(to: newRect) else {
              return nil
          }
          
          return UIImage(cgImage: croppedImage)
      }
      
      /// Scales the image to the specified size in the RGB color space.
      ///
      /// - Parameters:
      ///   - scaleFactor: Factor by which the image should be scaled.
      /// - Returns: The scaled image.
      func scaledImage(scaleFactor: CGFloat) -> UIImage? {
          guard let cgImage = self.cgImage else { return nil }
          
          let customColorSpace = CGColorSpaceCreateDeviceRGB()
          
          let width = CGFloat(cgImage.width) * scaleFactor
          let height = CGFloat(cgImage.height) * scaleFactor
          let bitsPerComponent = cgImage.bitsPerComponent
          let bytesPerRow = cgImage.bytesPerRow
          let bitmapInfo = cgImage.bitmapInfo.rawValue
          
          guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: customColorSpace, bitmapInfo: bitmapInfo) else { return nil }
          
          context.interpolationQuality = .high
          context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
          
          return context.makeImage().flatMap { UIImage(cgImage: $0) }
      }
      
      /// Returns the data for the image in the PDF format
      func pdfData() -> Data? {
          // Typical Letter PDF page size and margins
          let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
          let margin: CGFloat = 40
          
          let imageMaxWidth = pageBounds.width - (margin * 2)
          let imageMaxHeight = pageBounds.height - (margin * 2)
          
          let image = scaledImage(scaleFactor: size.scaleFactor(forMaxWidth: imageMaxWidth, maxHeight: imageMaxHeight)) ?? self
          let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

          let data = renderer.pdfData { (ctx) in
              ctx.beginPage()
              
              ctx.cgContext.interpolationQuality = .high

              image.draw(at: CGPoint(x: margin, y: margin))
          }
          
          return data
      }
    
      /// Function gathered from [here](https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer) to convert UIImage to CVPixelBuffer
      ///
      /// - Returns: new [CVPixelBuffer](apple-reference-documentation://hsVf8OXaJX)
      func pixelBuffer() -> CVPixelBuffer? {
          let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
          var pixelBufferOpt: CVPixelBuffer?
          let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBufferOpt)
          guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOpt else {
              return nil
          }

          CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
          let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

          let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
          guard let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
          }

          context.translateBy(x: 0, y: self.size.height)
          context.scaleBy(x: 1.0, y: -1.0)

          UIGraphicsPushContext(context)
          self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
          UIGraphicsPopContext()
          CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

          return pixelBuffer
      }

      /// Creates a UIImage from the specified CIImage.
      static func from(ciImage: CIImage) -> UIImage {
          if let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) {
              return UIImage(cgImage: cgImage)
          } else {
              return UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
          }
      }
}


extension UIImage {
    
    /// Data structure to easily express rotation options.
    struct RotationOptions: OptionSet {
        let rawValue: Int
        
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    /// Returns the same image with a portrait orientation.
    func applyingPortraitOrientation() -> UIImage {
        switch imageOrientation {
        case .up:
            return rotated(by: Measurement(value: Double.pi, unit: .radians), options: []) ?? self
        case .down:
            return rotated(by: Measurement(value: Double.pi, unit: .radians), options: [.flipOnVerticalAxis, .flipOnHorizontalAxis]) ?? self
        case .left:
            return self
        case .right:
            return rotated(by: Measurement(value: Double.pi / 2.0, unit: .radians), options: []) ?? self
        default:
            return self
        }
    }

    /// Rotate the image by the given angle, and perform other transformations based on the passed in options.
    ///
    /// - Parameters:
    ///   - rotationAngle: The angle to rotate the image by.
    ///   - options: Options to apply to the image.
    /// - Returns: The new image rotated and optentially flipped (@see options).
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        let cgImageSize = CGSize(width: cgImage.width, height: cgImage.height)
        var rect = CGRect(origin: .zero, size: cgImageSize).applying(transform)
        rect.origin = .zero
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
        
        let image = renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))
            
            let drawRect = CGRect(origin: CGPoint(x: -cgImageSize.width / 2.0, y: -cgImageSize.height / 2.0), size: cgImageSize)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
        
        return image
    }
    
    /// Rotates the image based on the information collected by the accelerometer
    func withFixedOrientation() -> UIImage {
        var imageAngle: Double = 0.0
        
        var shouldRotate = true
        switch CaptureSession.current.editImageOrientation {
        case .up:
            shouldRotate = false
        case .left:
            imageAngle = Double.pi / 2
        case .right:
            imageAngle = -(Double.pi / 2)
        case .down:
            imageAngle = Double.pi
        default:
            shouldRotate = false
        }
        
        if shouldRotate,
            let finalImage = rotated(by: Measurement(value: imageAngle, unit: .radians)) {
            return finalImage
        } else {
            return self
        }
    }
    
}
