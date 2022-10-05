//
//  Faces.swift
//  FaceDetector
//
//  Created by mystic on 2022/10/05.
//

import UIKit
import Vision

extension UIImage {
    func detectFaces(completion: @escaping ([VNFaceObservation]?) -> ()) {
        guard let image = self.cgImage else { return completion(nil) }
        let request = VNDetectFaceRectanglesRequest()
        DispatchQueue.global().async {
            let handler = VNImageRequestHandler(
                cgImage: image,
                orientation: self.cgImageOrientation
            )
            try? handler.perform([request])
            guard let observation = request.results else { return completion(nil) }
            completion(observation)
        }
    }
}

extension Collection where Element == VNFaceObservation {
    func drawOn(_ image: UIImage) -> UIImage? {
        let width = image.size.width
        let height = image.size.height
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.01*image.size.width)
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -height)
        for observation in self {
            let rect = observation.boundingBox
            let normalizedRect = VNImageRectForNormalizedRect(rect, Int(width), Int(height))
                .applying(transform)
            context.stroke(normalizedRect)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
