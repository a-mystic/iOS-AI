//
//  Similarity.swift
//  ImageSimilarity
//
//  Created by mystic on 2022/10/06.
//

import UIKit
import Vision

extension UIImage {
    func similarity(to image: UIImage) -> Float? {
        var similarity: Float = 0
        guard let firstImageFPO = self.featurePrintObservation(),
              let secondImageFPO = image.featurePrintObservation(),
              let _ = try? secondImageFPO.computeDistance(&similarity, to: firstImageFPO) else {
            return nil
        }
        return similarity
    }
    
    private func featurePrintObservation() -> VNFeaturePrintObservation? {
        guard let cgImage = self.cgImage else { return nil }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: self.cgImageOrientation, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        if let _ = try? requestHandler.perform([request]), let result = request.results?.first as? VNFeaturePrintObservation {
            return result
        }
            return nil
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
