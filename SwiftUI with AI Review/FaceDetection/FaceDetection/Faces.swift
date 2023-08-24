//
//  Faces.swift
//  FaceDetection
//
//  Created by a mystic on 2023/08/24.
//

import UIKit
import Vision

extension UIImage {
    func detectFaces(completion: @escaping ([VNFaceObservation]?) -> ()) {
        guard let image = self.cgImage else { return completion(nil) }
        let request = VNDetectFaceRectanglesRequest()
        Task {
            let handler = VNImageRequestHandler(cgImage: image, orientation: self.cgImageOrientation)
            try? handler.perform([request])
            guard let observations = request.results else { return completion(nil) }
            completion(observations)
        }
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
            @unknown default: return .up
            }
        }
}

extension Collection where Element == VNFaceObservation {
    func drawOn(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let width = image.size.width
        let height = image.size.height
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.01 * width)
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -height)
        for observation in self {
            let rect = observation.boundingBox
            let normalizedRect = VNImageRectForNormalizedRect(rect, Int(width), Int(height)).applying(transform)
            context.stroke(normalizedRect)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return result
    }
}
