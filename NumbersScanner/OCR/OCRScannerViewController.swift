//
//  OCRScannerViewController.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 06.03.2023.
//

import UIKit
import SwiftUI
import AVFoundation
import Vision

class OCRScannerViewController: UIViewController {

    var delegate: GFLiveScannerDelegate?
    private var screenRect: CGRect! = nil
    private var permissionGranted = false

    private let captureSession = AVCaptureSession()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let videoOutput = AVCaptureVideoDataOutput()

    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let ocrEngine = OCREngine()

    override func viewDidLoad() {
        checkPermission()
        startScanning()
    }

    func startScanning() {
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }

    func stopScanning() {
        sessionQueue.async { [unowned self] in
            self.captureSession.stopRunning()
        }
    }

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
                // Permission has been granted before
            case .authorized:
                permissionGranted = true

                // Permission has not been requested yet
            case .notDetermined:
                requestPermission()

            default:
                permissionGranted = false
        }
    }

    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }

    func setupCaptureSession() {
        guard setupCaptureSessionInput() else { return }
        setupCaptureSessionPreview()
        setupCaptureSessionOutput()
    }

    func setupCaptureSessionInput() -> Bool {
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            return false
        }

        captureSession.addInput(videoDeviceInput)

        // make a little zoom in the camera preview to be able to scan from a monitor
        do {
            try videoDevice.lockForConfiguration()
            if videoDevice.activeFormat.videoMaxZoomFactor >= 8.0 {
                videoDevice.videoZoomFactor = 8.0
            }
            videoDevice.unlockForConfiguration()
        } catch {
            print("Could not configure video device: \(error)")
        }

        return true
    }

    func setupCaptureSessionPreview() {
        previewLayer.session = captureSession
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait

        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.opacity = 0.6
        previewLayer.addSublayer(maskLayer)

        let regionOfInterestOutline = CAShapeLayer()
        regionOfInterestOutline.path = UIBezierPath(rect: rectOfInterest).cgPath
        regionOfInterestOutline.fillColor = UIColor.clear.cgColor
        regionOfInterestOutline.strokeColor = UIColor.yellow.cgColor
        previewLayer.addSublayer(regionOfInterestOutline)

        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self?.view.layer.addSublayer(self!.previewLayer)
            self?.previewLayer.frame = self?.view.layer.bounds ?? CGRect()
        }
    }

    func setupCaptureSessionOutput() {
        // Detector
        videoOutput.videoSettings = [
            String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)
        ]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        videoOutput.connection(with: .video)?.videoOrientation = .portrait


        videoOutput.alwaysDiscardsLateVideoFrames = true

        captureSession.addOutput(videoOutput)
    }

    var rectOfInterest: CGRect {
        previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)
    }
}

extension OCRScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

        guard let image = getCGImageFromSampleBuffer(sampleBuffer),
              let croppedImage = image.cropTo(rect: rectOfInterest) else {
            return
        }

        ocrEngine.getTextFromImage(croppedImage) { result in
            switch result {
                case .success(let string):
                    self.delegate?.capturedString(string)
                default:
                    break
            }
        }
    }

    /// Returns if possible a CGImage from a CMSampleBuffer
    /// - Parameter sampleBuffer: The CMSampleBuffer to convert to an image
    /// - Returns: The optional CGImage
    func getCGImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> CGImage? {
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
}

/// Describes the delegate of GFLiveScanner

public protocol GFLiveScannerDelegate {

    /// Called when an array of strings has been captured
    /// May contain OCR text or a list of barcodes
    /// - Parameter strings: The strings detected during live scan

    func capturedString(_ string: String)
}
