//
//  TesseractOCRScanner.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/07/28.
//


//import UIKit
//import TesseractOCR
//
//class TesseractOCRScanner: OCRScanner {
//    func requestOCR(with sourceImage: UIImage, completed: @escaping ([OCRResult]?) -> Void) {
//        guard let tesseract = G8Tesseract(language: "kor+eng") else {
//            return
//        }
//
//        tesseract.engineMode = .tesseractOnly
//        tesseract.pageSegmentationMode = .auto
//        tesseract.image = sourceImage
//
//        var ocrResult: [OCRResult] = []
//
//        if tesseract.recognize(),
//           let recognizedText = tesseract.recognizedText {
//            let words = recognizedText.components(separatedBy: "\n")
//            for word in words {
//                ocrResult.append(OCRResult(word: word, box: nil))
//            }
//
//            completed(ocrResult)
//        } else {
//
//            completed(nil)
//        }
//    }
//}
