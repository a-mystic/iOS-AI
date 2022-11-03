//
//  ImageProcess.swift
//  FacialEmotionDetection
//
//  Created by mystic on 2022/10/30.
//

import UIKit
import Vision

protocol ImageProcessorDelegate: class {
    func onImageProcessorCompleted(status: Int, faces: [MLMultiArray]?)
}

class ImageProcessor {
    weak var delegate: ImageProcessorDelegate?
    let faceDetection = VNDetectFaceRectanglesRequest()
    let faceDetectionRequest = VNSequenceRequestHandler()
    
    init() { }
    
    public func getFaces(pixelBuffer: CVPixelBuffer) {
        DispatchQueue.global(qos: .background).async {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let width = ciImage.extent.width
            let height = ciImage.extent.height
            try? self.faceDetectionRequest.perform([self.faceDetection], on: ciImage)
            var facesData = [MLMultiArray]()
            if let faceDetectionResults = self.faceDetection.results as? [VNFaceObservation] {
                for face in faceDetectionResults {
                    let bbox = face.boundingBox
                    let imageSize = CGSize(width:width, height:height)
                    let w = bbox.width * imageSize.width
                    let h = bbox.height * imageSize.height
                    let x = bbox.origin.x * imageSize.width
                    let y = bbox.origin.y * imageSize.height
                    let paddingTop = h * 0.2
                    let paddingBottom = h * 0.55
                    let paddingWidth = w * 0.15
                    let faceRect = CGRect(
                              x: max(x - paddingWidth, 0),
                              y: max(0, y - paddingTop),
                              width: min(w + (paddingWidth * 2), imageSize.width),
                              height: min(h + paddingBottom, imageSize.height)
                    )
                    if let pixelData = ciImage.crop(rect: faceRect)?.resize(size: CGSize(width: 48, height: 48)).getGrayscalePixelData()?.map { pixel in
                        return Double(pixel) / 255.0
                    } {
                        if let array = try? MLMultiArray(shape: [1, 48, 48], dataType: .double) {
                            for (index, element) in pixelData.enumerated() {
                                array[index] = NSNumber(value: element)
                            }
                            facesData.append(array)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.delegate?.onImageProcessorCompleted(status: 1, faces: facesData)
                }
            }
        }
    }
}
