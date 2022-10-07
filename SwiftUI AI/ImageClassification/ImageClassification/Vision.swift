//
//  Vision.swift
//  ImageClassification
//
//  Created by mystic on 2022/10/07.
//

import UIKit
import CoreML
import Vision
import SwiftUI

extension VNImageRequestHandler {
    convenience init?(uiImage: UIImage) {
        guard let ciImage = CIImage(image: uiImage) else { return nil }
        let orientation = uiImage.cgImageOrientation
        self.init(ciImage: ciImage, orientation: orientation)
    }
}

class VisionClassifier {
    private let model: VNCoreMLModel
    private var SuccessAction: ((String) -> ())?
    private lazy var requests: [VNCoreMLRequest] = {
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.handleResults(for: request, error: error)
        }
        request.imageCropAndScaleOption = .centerCrop
        return [request]
    }()
    
    init?(mlmodel: MLModel) {
        if let model = try? VNCoreMLModel(for: mlmodel) {
            self.model = model
        } else {
            return nil
        }
    }
    
    func classify(_ image: UIImage, SuccessAction: ((String) -> ())?) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let handler = VNImageRequestHandler(uiImage: image) else { return }
            do {
                try handler.perform(self.requests)
            } catch {
                print(error)
            }
            if let SuccessAction = SuccessAction {
                self.SuccessAction = SuccessAction
            }
        }
    }
    
    func handleResults(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            if !results.isEmpty {
                let result = results[0]
                if let SuccessAction = self.SuccessAction {
                    SuccessAction("\(result.identifier)" + "(\(Int(result.confidence * 100))%)")
                }
            }
        }
    }
}

extension UIImage {
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
