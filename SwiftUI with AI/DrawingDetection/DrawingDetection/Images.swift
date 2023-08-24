//
//  Images.swift
//  DrawingDetection
//
//  Created by mystic on 2022/10/09.
//

import UIKit

extension CIFilter {
    static let mono = CIFilter(name: "CIPhotoEffectMono")!
    static let noir = CIFilter(name: "CIPhotoEffectNoir")!
    static let tonal = CIFilter(name: "CIPhotoEffectTonal")!
    static let invert = CIFilter(name: "CIColorInvert")!
    
    static func contrast(amount: Double = 2.0) -> CIFilter {
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(amount, forKey: kCIInputContrastKey)
        return filter
    }
    
    static func brighten(amount: Double = 0.1) -> CIFilter {
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(amount, forKey: kCIInputBrightnessKey)
        return filter
    }
}

extension UIImage {
    func applying(filter: CIFilter) -> UIImage? {
        filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let output = filter.outputImage, let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func fixOrientation() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    var cgImageOrientation: CGImagePropertyOrientation {
            switch self.imageOrientation {
            case .up: return .up
            case .down: return .down
            case .left: return .left
            case .right: return .right
            case .upMirrored: return .upMirrored
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .rightMirrored: return .rightMirrored
            }
        }
}
