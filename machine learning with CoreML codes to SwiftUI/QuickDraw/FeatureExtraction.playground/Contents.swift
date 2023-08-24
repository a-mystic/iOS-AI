//: (Start) Playground to explore feature extraction

import UIKit
import Accelerate
import CoreML

let histogramViewFrame = CGRect(x: 0, y: 0, width: 600, height: 300)
let heatmapViewFrame = CGRect(x: 0, y: 0, width: 600, height: 600)
let sketchFeatureExtractor = cnnsketchfeatureextractor()
let targetSize = CGSize(width: 256, height: 256)
let context = CIContext()

func extractFeaturesFromImage(image: UIImage) -> MLMultiArray? {
    guard let image = CIImage(image: image) else { return nil }
    return extractFeaturesFromImage(image: image)
}

func extractFeaturesFromImage(image: CIImage) -> MLMultiArray? {
    guard let imagePixelBuffer = image
        .resize(size: targetSize)
        .rescalePixels()?
        .toPixelBuffer(context: context, gray: true) else { return nil }
    guard let features = try? sketchFeatureExtractor.prediction(image: imagePixelBuffer) else { return nil }
    return features.classActivations
}

var images = [UIImage]()
var imageFeatures = [MLMultiArray]()

for i in 1...6 {
    guard let image = UIImage(named: "images/cat_\(i).png"),
          let features = extractFeaturesFromImage(image: image) else {
        fatalError("Failed to extract features")
    }
    images.append(image)
    imageFeatures.append(features)
}

for i in 0..<6 {
    let img = images[i]
    let hist = HistogramView(frame: histogramViewFrame, data: imageFeatures[0])
}

func dot(vecA: MLMultiArray, vecB: MLMultiArray) -> Double {
    guard vecA.shape.count == 1 && vecB.shape.count == 1 else { fatalError() }
    guard vecA.count == vecB.count else { fatalError() }
    let count = vecA.count
    let vecAPtr = UnsafeMutablePointer<Double>(OpaquePointer(vecA.dataPointer))
    let vecBPtr = UnsafeMutablePointer<Double>(OpaquePointer(vecB.dataPointer))
    var output: Double = 0.0
    vDSP_dotprD(vecAPtr, 1, vecBPtr, 1, &output, vDSP_Length(count))
    var x: Double = 0
    for i in 0..<vecA.count {
        x += vecA[i].doubleValue * vecB[i].doubleValue
    }
    return x
}

func magnitude(vec: MLMultiArray) -> Double {
    guard vec.shape.count == 1 else { fatalError() }
    let count = vec.count
    let vecPtr = UnsafeMutablePointer<Double>(OpaquePointer(vec.dataPointer))
    var output: Double = 0.0
    vDSP_svsD(vecPtr, 1, &output, vDSP_Length(count))
    return sqrt(output)
}

var similarities = Array(repeating: Array(repeating: 0.0, count: images.count), count: images.count)

for i in imageFeatures.indices {
    for j in imageFeatures.indices {
        let sim = dot(vecA: imageFeatures[i], vecB: imageFeatures[j])
        similarities[i][j] = sim
    }
}

let heatmap = HeatmapView(frame: heatmapViewFrame, images: images, data: similarities)
