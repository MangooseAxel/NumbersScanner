//
//  OCREngine.swift
//  GFLiveScanner
//
//  Created by Oleksandr Dolomanov on 11.03.2023.
//

import UIKit
import Vision

/// Convenience typealias for the callback function passed to the OCR class
public typealias OCREngineCallback = (Result<String, Error>) -> Void

/// Helper struct for OCREngine
/// containing the CGImage to process and the callback to call
/// once the OCR is done
fileprivate struct OCREngineRequest {
    var image: CGImage
    var callback: OCREngineCallback
}

/// Helper class to get text from an image using Vision framework
/// It is possibile to configure the OCR to perform fast with less accuracy
/// or slow but with better accuracy

public class OCREngine {
    private var pendingOCRRequests: [OCREngineRequest] = []
    private var imageSize: CGSize = .zero

    /// Get an array of strings from a CGImage
    /// - Parameters:
    ///   - image: The CGImage to scan for text
    ///   - callback: the callback with a bool parameter indicating success
    ///                 and an optional array of string recognized in the image
    public func getTextFromImage(
        _ image: CGImage,
        callback: @escaping OCREngineCallback
    ) {
        if imageSize == .zero {
            imageSize = .init(width: image.width, height: image.height)
        }
        addRequest(withImage: image, callback: callback)
    }
    
    /// Add a request for OCR
    /// - Parameters:
    ///   - image: The CGImage to scan for text
    ///   - callback: callback with the recognized text
    private func addRequest(
        withImage image: CGImage,
        callback: @escaping OCREngineCallback
    ) {
        let request = OCREngineRequest(image: image, callback: callback)
        pendingOCRRequests.append(request)
        if pendingOCRRequests.count == 1 {
            processOCRRequest(request)
        }
    }
    
    /// Process the next request in queue
    /// - Parameter request: The OCREngineRequest to process
    private func processOCRRequest(_ request: OCREngineRequest) {
        let requestHandler = VNImageRequestHandler(
            cgImage: request.image,
            orientation: CGImagePropertyOrientation.right,
            options: [:]
        )

        let visionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        visionRequest.recognitionLevel = .accurate
        visionRequest.usesLanguageCorrection = false

        do {
            try requestHandler.perform([visionRequest])
        } catch {
            print("Error while performing vision request: \(error).")
            currentRequestProcessed(string: nil)
        }
    }
    
    /// The handler called by Vision when an image has been processed
    /// - Parameters:
    ///   - request: the VNRequest processed
    ///   - error: optional Error
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            currentRequestProcessed(string: nil)
            return
        }

        // Sort the recognized strings based on their distance from the center of the image
        let recognizedStrings = observations.compactMap { observation -> (String, CGFloat)? in
            guard let candidate = observation.topCandidates(1).first else { return nil }

            let boundingBox = observation.boundingBox
            let boundingBoxCenter = CGPoint(
                x: boundingBox.origin.x + (boundingBox.width / 2),
                y: boundingBox.origin.y + (boundingBox.height / 2)
            )
            let distance = boundingBoxCenter.distanceTo(point: CGPoint(x: 0.5, y: 0.5))

            return (candidate.string, CGFloat(distance))
        }
            .sorted { $0.1 < $1.1 } // sort by distance

        currentRequestProcessed(string: recognizedStrings.first?.0)
    }
    
    /// Called when the current request has been processed
    /// - Parameter string: Optional recognized text
    private func currentRequestProcessed(string: String?) {
        guard let request = pendingOCRRequests.first else { return }

        pendingOCRRequests.removeFirst()
        let callback = request.callback

        if let string {
            callback(.success(string))
        } else {
            callback(.failure(NSError(
                domain: "GFLiveScanner",
                code: 0,
                userInfo: ["Message" : "cannot perform OCR on image"]
            )))
        }
    }
}
