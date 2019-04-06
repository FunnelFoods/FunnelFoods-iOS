//
//  OCR.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 5/4/19.
//  Copyright © 2019 Funnel. All rights reserved.
//

import UIKit
import TesseractOCR


class OCR: NSObject, G8TesseractDelegate {
    
    let tesseract = G8Tesseract(language: "eng")!

    func output(image: UIImage) -> String {
        tesseract.engineMode = .lstmOnly
        tesseract.pageSegmentationMode = .auto // Enable orientation detection with tesseract.pageSegmentationMode = .autoOSD
        tesseract.image = image.scaleImage(640)!
        tesseract.recognize()
        print("Text: \(tesseract.recognizedText!)")
        return tesseract.recognizedText
   }
}

// MARK: - UIImage extension
extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
