//
//  GFOcrHelper.swift
//  GFLiveScanner
//
//  Created by Gualtiero Frigerio on 21/11/2020.
//

import Foundation
import UIKit
import Vision

/// Convenience typealias for the callback function passed to the OCR class
public typealias GFOcrHelperCallback = (Result<[String], Error>) -> Void

/// Helper struct for OCRHelper
/// containing the CGImage to process and the callback to call
/// once the OCR is done
fileprivate struct GFOcrHelperRequest {
    var image: CGImage
    var orientation: CGImagePropertyOrientation?
    var callback: GFOcrHelperCallback
}

/// Helper class to get text from an image using Vision framework
/// It is possibile to configure the OCR to perform fast with less accuracy
/// or slow but with better accuracy
@available(iOS 13.0, *)
public class GFOcrHelper {
    public var useFastRecognition = false
    
    public init(fastRecognition: Bool) {
        self.useFastRecognition = fastRecognition
    }
    /// Get an array of strings from a UIImage
    /// - Parameters:
    ///   - image: The UIImage to scan for text
    ///   - callback: the callback with a bool parameter indicating success
    ///                 and an optional array of string recognized in the image
    public func getTextFromImage(
        _ image: UIImage,
        callback: @escaping GFOcrHelperCallback
    ) {
        guard let cgImage = image.cgImage else {
            callback(.failure(genericError))
            return
        }
        if imageSize == CGSize() {
            imageSize = image.size
        }
        addRequest(withImage: cgImage, orientation:nil, callback: callback)
    }

    /// Get an array of strings from a CGImage
    /// - Parameters:
    ///   - image: The CGImage to scan for text
    ///   - orientation: The adjusted orientation of the image
    ///   - callback: the callback with a bool parameter indicating success
    ///                 and an optional array of string recognized in the image
    public func getTextFromImage(
        _ image: CGImage,
        orientation: CGImagePropertyOrientation?,
        callback: @escaping GFOcrHelperCallback
    ) {
        if imageSize == CGSize() {
            imageSize = .init(width: image.width, height: image.height)
        }
        addRequest(withImage: image, orientation:orientation, callback: callback)
    }
    
    // MARK: - Private
    
    private var genericError:Error {
        GFLiveScannerUtils.createError(withMessage: "cannot perform OCR on image", code: 0)
    }
    private var pendingOCRRequests: [GFOcrHelperRequest] = []
    private var imageSize: CGSize = .zero
    
    /// Add a request for OCR
    /// - Parameters:
    ///   - image: The CGImage to scan for text
    ///   - orientation: the CGImage adjusted orientation
    ///   - callback: callback with the recognized text
    private func addRequest(
        withImage image: CGImage,
        orientation: CGImagePropertyOrientation?,
        callback: @escaping GFOcrHelperCallback
    ) {
        let request = GFOcrHelperRequest(image: image, orientation: orientation, callback: callback)
        pendingOCRRequests.append(request)
        if pendingOCRRequests.count == 1 {
            processOCRRequest(request)
        }
    }
    
    /// Process the next request in queue
    /// - Parameter request: The OCRHelperRequest to process
    private func processOCRRequest(_ request: GFOcrHelperRequest) {
        var requestHandler: VNImageRequestHandler

        if let orientation = request.orientation {
            requestHandler = VNImageRequestHandler(
                cgImage: request.image,
                orientation: orientation,
                options: [:]
            )
        } else {
            requestHandler = VNImageRequestHandler(cgImage: request.image)
        }

        let visionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        visionRequest.recognitionLevel = .accurate

        do {
            try requestHandler.perform([visionRequest])
        } catch {
            print("Error while performing vision request: \(error).")
            currentRequestProcessed(strings: nil)
        }
    }
    
    /// The handler called by Vision when an image has been processed
    /// - Parameters:
    ///   - request: the VNRequest processed
    ///   - error: optional Error
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            currentRequestProcessed(strings: nil)
            return
        }

        // Get the center of the image
        let centerX = imageSize.width / 2
        let centerY = imageSize.height / 2

        // Sort the recognized strings based on their distance from the center of the image
        let recognizedStrings = observations.compactMap { observation -> (String, CGFloat)? in
            guard let candidate = observation.topCandidates(1).first else { return nil }

            let boundingBox = observation.boundingBox
            let boundingBoxCenterX = boundingBox.origin.x + (boundingBox.size.width / 2)
            let boundingBoxCenterY = boundingBox.origin.y + (boundingBox.size.height / 2)
            let distance = sqrt(pow((centerX - boundingBoxCenterX), 2) + pow((centerY - boundingBoxCenterY), 2))

            return (candidate.string, distance)
        }
            .sorted { $0.1 < $1.1 } // sort by distance
        
        // Return the closest recognized string or nil if no strings were recognized
        let closestString = recognizedStrings.first?.0
        currentRequestProcessed(strings: closestString != nil ? [closestString!] : nil)
    }
    
    /// Called when the current request has been processed
    /// - Parameter strings: Optional array with recognized text
    private func currentRequestProcessed(strings: [String]?) {
        guard let request = pendingOCRRequests.first else { return }

        pendingOCRRequests.removeFirst()
        let callback = request.callback

        if let strings = strings {
            callback(.success(strings))
        } else {
            callback(.failure(genericError))
        }
    }
}
