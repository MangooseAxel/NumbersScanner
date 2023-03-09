//
//  GFLiveScannerUtils.swift
//  GFLiveScanner
//
//  Created by Gualtiero Frigerio on 21/11/2020.
//

import AVFoundation
import CoreGraphics
import UIKit

/// Class with static function needed by the live scanner
/// like getting the current screen orientation
/// converting the SampleBuffer to a CGImage or UIImage
/// and get the correct orientation for images or video
/// coming from AVCaptureSession based on the device orientation
class GFLiveScannerUtils {
    /// Creates an NSError with a string and a code
    /// - Parameters:
    ///   - withMessage: the String with the error message
    ///   - code: the error code
    /// - Returns: An NSError
    class func createError(withMessage:String, code:Int) -> NSError {
        let error = NSError(domain: "GFLiveScanner", code: code, userInfo: ["Message" : withMessage])
        return error
    }

    /// Returns if possible a CGImage from a CMSampleBuffer
    /// - Parameter sampleBuffer: The CMSampleBuffer to convert to an image
    /// - Returns: The optional CGImage
    class func getCGImageFromSampleBuffer(_ sampleBuffer:CMSampleBuffer) -> CGImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width,
                                      height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                      space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        let cgImage = context.makeImage()
        
        return cgImage
    }
    /// Tries to get a UIImage from a CMSampleBuffer with an orientation
    /// - Parameters:
    ///   - sampleBuffer: The CMSampleBuffer containing the image
    ///   - orientation: The desired orientation
    /// - Returns: An optional UIImage
    class func getUIImageFromSampleBuffer(_ sampleBuffer:CMSampleBuffer, orientation:UIInterfaceOrientation) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return nil}
        var cImage = CIImage(cvImageBuffer: imageBuffer)
        cImage = getOrientedImage(cImage, forOrientation: orientation)
        return UIImage(ciImage: cImage)
    }
    
    /// Returnes a CIImage rotated based on the given orientation
    /// - Parameters:
    ///   - image: The image to rotate
    ///   - orientation: The desired orientation
    /// - Returns: The rotated image
    class func getOrientedImage(_ image:CIImage, forOrientation orientation:UIInterfaceOrientation) -> CIImage {
        var cImage = image
        switch orientation {
        case .portrait:
            cImage = cImage.oriented(forExifOrientation: 6)
            break
        case .portraitUpsideDown:
            cImage = cImage.oriented(forExifOrientation: 8)
            break
        case .landscapeLeft:
            cImage = cImage.oriented(forExifOrientation: 3)
            break
        case .landscapeRight:
            cImage = cImage.oriented(forExifOrientation: 1)
            break
        default:
            break
        }
        return cImage
    }
}
