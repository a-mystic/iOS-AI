//
//  Image.swift
//  StyleTransfer
//
//  Created by mystic on 2022/10/16.
//

import UIKit

extension UIImage {
    static let placeholder = UIImage(systemName: "photo")
    
    func styled(with modelSelection: StyleModel) -> UIImage? {
        guard let inputPixelBuffer = self.pixelBuffer() else { return nil }
        let model = modelSelection.model
        let transformation = try? model.prediction(image: inputPixelBuffer, index: modelSelection.styleArray)
        guard let outputPixelBuffer = transformation?.stylizedImage else { return nil }
        let outputImage = outputPixelBuffer.perform(permission: .readOnly) {
            guard let outputContext = CGContext.createContext(for: outputPixelBuffer) else { return nil }
            return outputContext.makeUIIamge()
        } as UIImage?
        return outputImage
    }
    
    func aspectFilled(to size: CGSize) -> UIImage? {
        if self.size == size { return self }
        let (width, height) = (Int(size.width), Int(size.height))
        let aspectRatio = self.size.width / self.size.height
        let intermediateSize: CGSize
        if aspectRatio > 0 {
            intermediateSize = CGSize(width: Int(aspectRatio*size.height), height: height)
        } else {
            intermediateSize = CGSize(width: width, height: Int(aspectRatio*size.width))
        }
        return self.resized(to: intermediateSize)?.cropped(to: size)
    }
    
    func resized(to size: CGSize) -> UIImage? {
        let newRect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func cropped(to size: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let widthDifference = self.size.width - size.width
        let heightDifference = self.size.height - size.height
        if widthDifference + heightDifference == 0 { return self }
        if min(widthDifference, heightDifference) < 0 { return nil }
        let newRect = CGRect(x: widthDifference/2, y: heightDifference/2, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), byTiling: false)
        context?.clip(to: [newRect])
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        guard let image = self.cgImage else { return nil }
        let dimensions: (height: Int, width: Int) = (Int(self.size.width), Int(self.size.height))
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            dimensions.width,
            dimensions.height,
            kCVPixelFormatType_32BGRA,
            [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary,
            &pixelBuffer
        )
        guard let createdPixelBuffer = pixelBuffer, status == kCVReturnSuccess else { return nil }
        let popluatedPixelBuffer = createdPixelBuffer.perform(permission: .readAndWrite) {
            guard let graphicsContext = CGContext.createContext(for: createdPixelBuffer) else {
                return nil
            }
            graphicsContext.draw(image, in: CGRect(x: 0, y: 0, width: dimensions.width, height: dimensions.height))
            return createdPixelBuffer
        } as CVPixelBuffer?
        return popluatedPixelBuffer
    }
}
